//
//  AuthManager.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 20.10.26.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
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
            NotificationStore.shared.add(
                kind: .system,
                title: "Qeydiyyat tamamlandı",
                message: "Hesabınız uğurla yaradıldı. ElmiYol-a xoş gəlmisiniz!"
            )
            NotificationStore.shared.refreshSessionCount()
            Task { await AvatarStore.shared.refresh() }
            PlannerStore.shared.start()
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
            NotificationStore.shared.add(
                kind: .system,
                title: "Qeydiyyat tamamlandı",
                message: "Hesabınız uğurla yaradıldı. ElmiYol-a xoş gəlmisiniz!"
            )
            NotificationStore.shared.refreshSessionCount()
            Task { await AvatarStore.shared.refresh() }
            PlannerStore.shared.start()
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
            PlannerStore.shared.stop()
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
                NotificationStore.shared.refreshSessionCount()
                Task { await AvatarStore.shared.refresh() }
                PlannerStore.shared.start()
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
        guard let message = AuthErrorMessage.text(for: error) else { return }
        showMessage(message, title: "Giriş alınmadı")
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
    
}

private enum AuthManagerError: LocalizedError {
    case missingProviderToken(String)
    
    var errorDescription: String? {
        if case .missingProviderToken(let message) = self { return message }
        return nil
    }
}
