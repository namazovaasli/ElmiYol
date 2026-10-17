import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Security
import SwiftUI
import UIKit
import Combine

enum AuthFlowDestination: Hashable {
    case login
    case roleSelection
    case studentRegistration
    case supervisorRegistration
}

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var user: User?
    @Published private(set) var role: UserRole?
    @Published private(set) var needsRoleSelection = false
    @Published private(set) var isResolvingSession = true
    @Published private(set) var isBusy = false
    @Published var path: [AuthFlowDestination] = []
    @Published var alertTitle = "ElmiYol"
    @Published var alertMessage: String?
    @Published var isEmailPromptPresented = false
    @Published var emailForEmailLink = ""
    
    private var currentNonce: String?
    private var providerFirstName = ""
    private var providerLastName = ""
    private var incomingEmailLink: String?
    private var authListener: AuthStateDidChangeListenerHandle?
    private var profileLoadGeneration = 0
    private var registrationInProgress = false
    
    var isCompletingOAuthProfile: Bool {
        user != nil && needsRoleSelection
    }
    
    var registrationEmail: String {
        user?.email ?? ""
    }
    
    var registrationFirstName: String {
        if !providerFirstName.isEmpty { return providerFirstName }
        guard let name = user?.displayName else { return "" }
        return name.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? ""
    }
    
    var registrationLastName: String {
        if !providerLastName.isEmpty { return providerLastName }
        guard let name = user?.displayName else { return "" }
        let pieces = name.split(whereSeparator: \.isWhitespace)
        return pieces.dropFirst().joined(separator: " ")
    }
    
    init() {
        guard FirebaseAuthService.shared.isConfigured else {
            isResolvingSession = false
            return
        }
        
        user = FirebaseAuthService.shared.currentUser
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor [weak self] in
                await self?.receiveAuthState(user)
            }
        }
    }
    
    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
    
    func signIn(email: String, password: String) async {
        await performAuthAction {
            let user = try await Self.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            await self.resolveProfile(for: user)
        }
    }
    
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            show(FirebaseAuthServiceError.googleSignInNotConfigured)
            return
        }
        guard let presenter = Self.topViewController() else {
            showMessage("Google giriş pəncərəsini açmaq mümkün olmadı.")
            return
        }
        
        await performAuthAction {
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            let googleUser = result.user
            self.providerFirstName = googleUser.profile?.givenName ?? ""
            self.providerLastName = googleUser.profile?.familyName ?? ""
            let idToken = try Self.require(googleUser.idToken?.tokenString, message: "Google hesabından giriş məlumatları alınmadı.")
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: googleUser.accessToken.tokenString
            )
            let signedInUser = try await Self.signIn(with: credential)
            await self.resolveProfile(for: signedInUser)
        }
    }
    
    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        guard let nonce = Self.randomNonce() else {
            currentNonce = nil
            showMessage("Təhlükəsiz Apple giriş sorğusu yaratmaq mümkün olmadı.", title: "Xəta")
            return
        }
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
    }
    
    func handleApple(_ result: Result<ASAuthorization, Error>) async {
        guard case .success(let authorization) = result,
              let appleUser = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentNonce,
              let tokenData = appleUser.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            if case .failure(let error) = result,
               (error as? ASAuthorizationError)?.code == .canceled {
                return
            }
            currentNonce = nil
            showMessage("Apple hesabından giriş məlumatları alınmadı.")
            return
        }
        currentNonce = nil
        if let name = appleUser.fullName {
            providerFirstName = name.givenName ?? ""
            providerLastName = name.familyName ?? ""
        }
        
        await performAuthAction {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: nonce,
                fullName: appleUser.fullName
            )
            let signedInUser = try await Self.signIn(with: credential)
            await self.resolveProfile(for: signedInUser)
        }
    }
    
    func sendPasswordReset(to email: String) async {
        await performAuthAction {
            try await Self.sendPasswordReset(to: email.trimmingCharacters(in: .whitespacesAndNewlines))
            self.showMessage("Şifrəni yeniləmək üçün təlimat e-poçtunuza göndərildi.")
        }
    }
    
    func sendEmailSignInLink(to email: String) async {
        await performAuthAction {
            try await Self.sendEmailSignInLink(to: email.trimmingCharacters(in: .whitespacesAndNewlines))
            self.emailForEmailLink = email.trimmingCharacters(in: .whitespacesAndNewlines)
            self.showMessage("Giriş bağlantısı e-poçt ünvanınıza göndərildi. Bağlantını bu cihazda açın.")
        }
    }
    
    func registerStudent(_ model: StudentRegisterModel) async {
        await performAuthAction {
            self.registrationInProgress = true
            defer { self.registrationInProgress = false }
            let user = try await Self.register(
                email: model.email,
                password: model.password,
                profileFields: FirebaseAuthService.shared.profileFields(for: model),
                publicFields: FirebaseAuthService.shared.publicProfileFields(for: model)
            )
            var savedModel = model
            savedModel.password = ""
            savedModel.confirmPassword = ""
            UserSession.shared.studentData = savedModel
            UserSession.shared.supervisorData = nil
            UserSession.shared.currentRole = .student
            self.profileLoadGeneration += 1
            self.user = user
            self.role = .student
            self.needsRoleSelection = false
            self.path = []
        }
    }
    
    func registerSupervisor(_ model: SupervisorRegisterModel) async {
        await performAuthAction {
            self.registrationInProgress = true
            defer { self.registrationInProgress = false }
            let user = try await Self.register(
                email: model.email,
                password: model.password,
                profileFields: FirebaseAuthService.shared.profileFields(for: model),
                publicFields: FirebaseAuthService.shared.publicProfileFields(for: model)
            )
            var savedModel = model
            savedModel.password = ""
            savedModel.confirmPassword = ""
            UserSession.shared.supervisorData = savedModel
            UserSession.shared.studentData = nil
            UserSession.shared.currentRole = .supervisor
            self.profileLoadGeneration += 1
            self.user = user
            self.role = .supervisor
            self.needsRoleSelection = false
            self.path = []
        }
    }
    
    func signOut() {
        do {
            try FirebaseAuthService.shared.signOut()
            GIDSignIn.sharedInstance.signOut()
            UserSession.shared.logout()
            providerFirstName = ""
            providerLastName = ""
            user = nil
            role = nil
            needsRoleSelection = false
            path = []
        } catch {
            show(error)
        }
    }
    
    func handleIncomingURL(_ url: URL) {
        if GIDSignIn.sharedInstance.handle(url) { return }
        guard FirebaseAuthService.shared.isEmailSignInLink(url) else { return }
        
        incomingEmailLink = url.absoluteString
        if let savedEmail = UserDefaults.standard.string(forKey: FirebaseAuthService.pendingEmailKey) {
            Task { await completeEmailSignIn(email: savedEmail) }
        } else {
            emailForEmailLink = ""
            isEmailPromptPresented = true
        }
    }
    
    func handleIncomingActivity(_ activity: NSUserActivity) {
        guard activity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = activity.webpageURL else { return }
        handleIncomingURL(url)
    }
    
    func completeEmailSignInFromPrompt() {
        Task { await completeEmailSignIn(email: emailForEmailLink) }
    }
    
    func dismissEmailPrompt() {
        incomingEmailLink = nil
        isEmailPromptPresented = false
    }
    
    func showMessage(_ message: String, title: String = "ElmiYol") {
        alertTitle = title
        alertMessage = message
    }
    
    private func completeEmailSignIn(email: String) async {
        guard let link = incomingEmailLink else { return }
        await performAuthAction {
            let user = try await Self.completeEmailSignIn(email: email, link: link)
            self.incomingEmailLink = nil
            self.isEmailPromptPresented = false
            await self.resolveProfile(for: user)
        }
    }
    
    private func receiveAuthState(_ user: User?) async {
        self.user = user
        guard let user else {
            profileLoadGeneration += 1
            role = nil
            needsRoleSelection = false
            isResolvingSession = false
            path = []
            UserSession.shared.logout()
            return
        }
        if registrationInProgress { return }
        await resolveProfile(for: user)
    }
    
    private func resolveProfile(for user: User) async {
        profileLoadGeneration += 1
        let generation = profileLoadGeneration
        isResolvingSession = true
        do {
            let profile = try await Self.loadProfile(for: user)
            guard generation == profileLoadGeneration, self.user?.uid == user.uid else { return }
            if let profile, let role = profile.role {
                profile.applyToSession()
                self.role = role
                needsRoleSelection = false
            } else {
                self.role = nil
                needsRoleSelection = true
                path = [.roleSelection]
                UserSession.shared.logout()
            }
        } catch {
            if generation == profileLoadGeneration {
                show(error)
            }
        }
        if generation == profileLoadGeneration {
            isResolvingSession = false
        }
    }
    
    private func performAuthAction(_ action: () async throws -> Void) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }
        do {
            try await action()
        } catch {
            show(error)
        }
    }
    
    private func show(_ error: Error) {
        showMessage(error.localizedDescription, title: "Giriş alınmadı")
    }
    
    private static func signIn(email: String, password: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            FirebaseAuthService.shared.signIn(email: email, password: password) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private static func signIn(with credential: AuthCredential) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            FirebaseAuthService.shared.signIn(with: credential) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private static func register(
        email: String,
        password: String,
        profileFields: [String: Any],
        publicFields: [String: Any]
    ) async throws -> User {
        try await withCheckedThrowingContinuation {
            continuation in
            FirebaseAuthService.shared.register(
                email: email,
                password: password,
                profileFields: profileFields,
                publicFields: publicFields
            ) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private static func loadProfile(
        for user: User
    ) async throws -> FirebaseUserProfile? {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<FirebaseUserProfile?, Error>) in
            
            FirebaseAuthService.shared.loadProfile(for: user) { result in
                continuation.resume(with: result)
            }
        }
    }
    private static func sendPasswordReset(to email: String) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            
            FirebaseAuthService.shared.sendPasswordReset(to: email) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private static func sendEmailSignInLink(to email: String) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            
            FirebaseAuthService.shared.sendEmailSignInLink(to: email) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    private static func completeEmailSignIn(email: String, link: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            FirebaseAuthService.shared.completeEmailSignIn(email: email, link: link) { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private static func require<T>(_ value: T?, message: String) throws -> T {
        guard let value else { throw AuthManagerError.missingProviderToken(message) }
        return value
    }
    
    private static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?.rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
    
    private static func randomNonce(length: Int = 32) -> String? {
        let characters = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var bytes = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes) == errSecSuccess else {
            return nil
        }
        return bytes.map { characters[Int($0) % characters.count] }.reduce(into: "") { $0.append($1) }
    }
    
    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }
}

private enum AuthManagerError: LocalizedError {
    case missingProviderToken(String)
    
    var errorDescription: String? {
        if case .missingProviderToken(let message) = self { return message }
        return nil
    }
}
