//
//  FirebaseAuthService.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

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
            "faculty": model.faculty,
            "specialityId": model.specialityId,
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
            "faculty": model.faculty,
            "specialityId": model.specialityId,
            "speciality": model.specialityField,
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

        if !name.isEmpty, name != user.displayName {
            let change = user.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges { _ in }
        }

        batch.commit { error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(error))
                } else {
                    completion(.success(user))
                }
            }
        }
    }
}
