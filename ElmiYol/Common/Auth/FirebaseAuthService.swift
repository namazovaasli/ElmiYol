import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

enum FirebaseAuthServiceError: LocalizedError {
    case firebaseNotConfigured
    case missingCurrentUser
    case missingProjectID
    case emailDoesNotMatchCurrentAccount
    case googleSignInNotConfigured

    var errorDescription: String? {
        switch self {
        case .firebaseNotConfigured:
            return "Firebase konfiqurasiyası tapılmadı. GoogleService-Info.plist faylını tətbiqə əlavə edin."
        case .missingCurrentUser:
            return "Aktiv istifadəçi hesabı tapılmadı."
        case .missingProjectID:
            return "Firebase layihəsinin ID-si tapılmadı."
        case .emailDoesNotMatchCurrentAccount:
            return "Daxil edilmiş e-poçt aktiv hesabla uyğun gəlmir."
        case .googleSignInNotConfigured:
            return "Google girişi hələ sazlanmayıb. Firebase Console-da Google provayderini aktiv edin və yenilənmiş GoogleService-Info.plist faylını layihəyə əlavə edin."
        }
    }
}

struct FirebaseUserProfile {
    let role: UserRole?
    private let fields: [String: Any]

    init(fields: [String: Any]) {
        self.fields = fields
        self.role = (fields["role"] as? String).flatMap(UserRole.init(rawValue:))
    }

    func applyToSession() {
        let session = UserSession.shared
        switch role {
        case .some(.student):
            var model = StudentRegisterModel()
            model.firstName = value("firstName")
            model.lastName = value("lastName")
            model.email = value("email")
            model.phone = value("phone")
            model.university = value("university")
            model.faculty = value("faculty")
            model.speciality = value("speciality")
            model.groupNumber = value("groupNumber")
            model.studyYears = value("studyYears")
            model.acceptedTerms = fields["acceptedTerms"] as? Bool ?? false
            model.universityId = value("universityId")
            model.facultyId = value("facultyId")
            model.specialityId = value("specialityId")
            session.studentData = model
            session.supervisorData = nil
            session.currentRole = .student
        case .some(.supervisor):
            var model = SupervisorRegisterModel()
            model.firstName = value("firstName")
            model.lastName = value("lastName")
            model.email = value("email")
            model.phone = value("phone")
            model.workplace = value("workplace")
            model.position = value("position")
            model.academicDegree = value("academicDegree")
            model.specialityField = value("specialityField")
            model.acceptedTerms = fields["acceptedTerms"] as? Bool ?? false
            model.workplaceId = value("universityId")
            model.facultyId = value("facultyId")
            session.studentData = nil
            session.supervisorData = model
            session.currentRole = .supervisor
        case .none:
            session.logout()
        }
    }

    private func value(_ key: String) -> String {
        fields[key] as? String ?? ""
    }
}

final class FirebaseAuthService {
    static let shared = FirebaseAuthService()
    static let pendingEmailKey = "firebase.pendingEmailLinkSignInEmail"
    
    private init() {}
    
    var isConfigured: Bool {
        FirebaseApp.app() != nil
    }
    
    var currentUser: User? {
        guard isConfigured else { return nil }
        return Auth.auth().currentUser
    }
    
    func register(
        email: String,
        password: String,
        profileFields: [String: Any],
        publicFields: [String: Any] = [:],
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(FirebaseAuthServiceError.firebaseNotConfigured))
            return
        }
        
        if let user = Auth.auth().currentUser {
            guard let currentEmail = user.email,
                  currentEmail.caseInsensitiveCompare(email) == .orderedSame else {
                completion(.failure(FirebaseAuthServiceError.emailDoesNotMatchCurrentAccount))
                return
            }
            saveProfile(profileFields, publicFields: publicFields, for: user, completion: completion)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let self, let user = result?.user else {
                completion(.failure(FirebaseAuthServiceError.missingCurrentUser))
                return
            }
            self.saveProfile(profileFields, publicFields: publicFields, for: user, completion: completion)
        }
    }
    
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(FirebaseAuthServiceError.firebaseNotConfigured))
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(FirebaseAuthServiceError.missingCurrentUser))
            }
        }
    }
    
    func signIn(
        with credential: AuthCredential,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(FirebaseAuthServiceError.firebaseNotConfigured))
            return
        }
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            } else {
                completion(.failure(FirebaseAuthServiceError.missingCurrentUser))
            }
        }
    }
    
    func loadProfile(
        for user: User,
        completion: @escaping (Result<FirebaseUserProfile?, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(FirebaseAuthServiceError.firebaseNotConfigured))
            return
        }
        
        Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let snapshot, snapshot.exists, let fields = snapshot.data() else {
                completion(.success(nil))
                return
            }
            completion(.success(FirebaseUserProfile(fields: fields)))
        }
    }
    
    func sendPasswordReset(to email: String, completion: @escaping (Error?) -> Void) {
        guard isConfigured else {
            completion(FirebaseAuthServiceError.firebaseNotConfigured)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    func sendEmailSignInLink(to email: String, completion: @escaping (Error?) -> Void) {
        guard isConfigured else {
            completion(FirebaseAuthServiceError.firebaseNotConfigured)
            return
        }
        guard let projectID = FirebaseApp.app()?.options.projectID else {
            completion(FirebaseAuthServiceError.missingProjectID)
            return
        }
        
        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://\(projectID).firebaseapp.com")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.aslinamazova.ElmiYol")
        
        Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: settings) { error in
            if error == nil {
                UserDefaults.standard.set(email, forKey: Self.pendingEmailKey)
            }
            completion(error)
        }
    }
    
    func isEmailSignInLink(_ url: URL) -> Bool {
        guard isConfigured else { return false }
        return Auth.auth().isSignIn(withEmailLink: url.absoluteString)
    }
    
    func completeEmailSignIn(
        email: String,
        link: String,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        guard isConfigured else {
            completion(.failure(FirebaseAuthServiceError.firebaseNotConfigured))
            return
        }
        Auth.auth().signIn(withEmail: email, link: link) { result, error in
            if let error {
                completion(.failure(error))
            } else if let user = result?.user {
                UserDefaults.standard.removeObject(forKey: Self.pendingEmailKey)
                completion(.success(user))
            } else {
                completion(.failure(FirebaseAuthServiceError.missingCurrentUser))
            }
        }
    }
    
    func profileFields(for model: StudentRegisterModel) -> [String: Any] {
        [
            "role": UserRole.student.rawValue,
            "firstName": model.firstName,
            "lastName": model.lastName,
            "email": model.email,
            "phone": model.phone,
            "university": model.university,
            "faculty": model.faculty,
            "speciality": model.speciality,
            "groupNumber": model.groupNumber,
            "studyYears": model.studyYears,
            "acceptedTerms": model.acceptedTerms,
            "updatedAt": FieldValue.serverTimestamp(),
            "universityId": model.universityId,
            "facultyId": model.facultyId,
            "specialityId": model.specialityId,
        ]
    }
    
    func profileFields(for model: SupervisorRegisterModel) -> [String: Any] {
        [
            "role": UserRole.supervisor.rawValue,
            "firstName": model.firstName,
            "lastName": model.lastName,
            "email": model.email,
            "phone": model.phone,
            "workplace": model.workplace,
            "position": model.position,
            "academicDegree": model.academicDegree,
            "specialityField": model.specialityField,
            "acceptedTerms": model.acceptedTerms,
            "updatedAt": FieldValue.serverTimestamp(),
            "universityId": model.workplaceId,
            "facultyId": model.facultyId,
        ]
    }
    
    func publicProfileFields(for model: StudentRegisterModel) -> [String: Any] {
        [
            "role": UserRole.student.rawValue,
            "firstName": model.firstName,
            "lastName": model.lastName,
            "universityId": model.universityId,
            "university": model.university,
            "facultyId": model.facultyId,
            "faculty": model.faculty,
            "specialityId": model.specialityId,
            "speciality": model.speciality,
            "studyYears": model.studyYears,
            "updatedAt": FieldValue.serverTimestamp()
        ]
    }
    
    func publicProfileFields(for model: SupervisorRegisterModel) -> [String: Any] {
        [
            "role": UserRole.supervisor.rawValue,
            "firstName": model.firstName,
            "lastName": model.lastName,
            "universityId": model.workplaceId,
            "university": model.workplace,
            "facultyId": model.facultyId,
            "faculty": model.specialityField,
            "position": model.position,
            "academicDegree": model.academicDegree,
            "updatedAt": FieldValue.serverTimestamp()
        ]
    }
    
    func signOut() throws {
        guard isConfigured else { return }
        try Auth.auth().signOut()
        UserDefaults.standard.removeObject(forKey: Self.pendingEmailKey)
    }
    
    private func saveProfile(
        _ fields: [String: Any],
        publicFields: [String: Any],
        for user: User,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        let name = [fields["firstName"] as? String, fields["lastName"] as? String]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        let change = user.createProfileChangeRequest()
        change.displayName = name.isEmpty ? user.displayName : name
        change.commitChanges { [weak self] error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let self else {
                completion(.failure(FirebaseAuthServiceError.missingCurrentUser))
                return
            }
            _ = self
            var values = fields
            values["uid"] = user.uid
            values["email"] = user.email ?? fields["email"]
            values["updatedAt"] = FieldValue.serverTimestamp()
            
            let db = Firestore.firestore()
            let batch = db.batch()
            batch.setData(values, forDocument: db.collection("users").document(user.uid), merge: true)
            
            if !publicFields.isEmpty {
                var publicValues = publicFields
                publicValues["uid"] = user.uid
                batch.setData(publicValues, forDocument: db.collection("publicProfiles").document(user.uid), merge: true)
            }
            
            batch.commit { error in
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        }
    }
    
    enum AuthCoordinator {
        static func route(user: User, in window: UIWindow, onError: @escaping (Error) -> Void) {
            FirebaseAuthService.shared.loadProfile(for: user) { result in
                switch result {
                case .success(let profile):
                    guard let profile, let role = profile.role else {
                        UserSession.shared.logout()
                        AppRouter.shared.setRoot(.roleSelection, in: window)
                        return
                    }
                    profile.applyToSession()
                    AppRouter.shared.setRoot(route(for: role), in: window)
                case .failure(let error):
                    onError(error)
                }
            }
        }
        
        static func route(for role: UserRole) -> Route {
            switch role {
            case .student: return .studentMainTabBar
            case .supervisor: return .supervisorMainTabBar
            }
        }
    }
}
