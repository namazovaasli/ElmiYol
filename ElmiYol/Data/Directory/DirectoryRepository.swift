//
//  DirectoryRepository.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

protocol DirectoryRepositoryProtocol {
    func supervisors(universityId: String?) async throws -> [PublicProfile]
    func students(universityId: String?) async throws -> [PublicProfile]
}

final class FirestoreDirectoryRepository: DirectoryRepositoryProtocol {
    static let shared = FirestoreDirectoryRepository()
    private init() {}

    func supervisors(universityId: String?) async throws -> [PublicProfile] {
        try await profiles(role: .supervisor, universityId: universityId)
    }

    func students(universityId: String?) async throws -> [PublicProfile] {
        try await profiles(role: .student, universityId: universityId)
    }

    private func profiles(role: UserRole, universityId: String?) async throws -> [PublicProfile] {
        guard FirebaseApp.app() != nil else {
            throw FirebaseAuthServiceError.firebaseNotConfigured
        }
        var query: Query = Firestore.firestore()
            .collection("publicProfiles")
            .whereField("role", isEqualTo: role.rawValue)
        if let universityId, !universityId.isEmpty {
            query = query.whereField("universityId", isEqualTo: universityId)
        }
        let snapshot = try await query.limit(to: 50).getDocuments()

        return snapshot.documents.compactMap { document -> PublicProfile? in
            let data = document.data()
            guard let rawRole = data["role"] as? String,
                  let role = UserRole(rawValue: rawRole) else { return nil }
            return PublicProfile(
                id: document.documentID,
                role: role,
                firstName: data["firstName"] as? String ?? "",
                lastName: data["lastName"] as? String ?? "",
                universityId: data["universityId"] as? String ?? "",
                university: data["university"] as? String ?? "",
                faculty: data["faculty"] as? String ?? "",
                speciality: data["speciality"] as? String ?? "",
                position: data["position"] as? String ?? "",
                academicDegree: data["academicDegree"] as? String ?? ""
            )
        }
        .sorted { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
    }
}
