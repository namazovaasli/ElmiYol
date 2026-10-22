//
//  CatalogRepository.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import FirebaseCore
import FirebaseFirestore
import Foundation

protocol CatalogRepositoryProtocol {
    func universities() async throws -> [CatalogItem]
    func faculties(universityId: String) async throws -> [CatalogItem]
    func specialities(universityId: String, facultyId: String) async throws -> [CatalogItem]
}

final class FirestoreCatalogRepository: CatalogRepositoryProtocol {
    static let shared = FirestoreCatalogRepository()
    private init() {}

    func universities() async throws -> [CatalogItem] {
        try await items(at: "universities")
    }

    func faculties(universityId: String) async throws -> [CatalogItem] {
        try await items(at: "universities/\(universityId)/faculties")
    }

    func specialities(universityId: String, facultyId: String) async throws -> [CatalogItem] {
        try await items(at: "universities/\(universityId)/faculties/\(facultyId)/specialities")
    }

    private func items(at path: String) async throws -> [CatalogItem] {
        guard FirebaseApp.app() != nil else {
            throw FirebaseAuthServiceError.firebaseNotConfigured
        }

        let snapshot = try await Firestore.firestore()
            .collection(path)
            .getDocuments()

        return snapshot.documents.compactMap { document -> (item: CatalogItem, order: Int)? in
            let data = document.data()
            guard let name = data["name"] as? String else { return nil }
            if let isActive = data["isActive"] as? Bool, !isActive { return nil }
            return (CatalogItem(id: document.documentID, name: name), data["order"] as? Int ?? Int.max)
        }
        .sorted {
            if $0.order != $1.order { return $0.order < $1.order }
            return $0.item.name.localizedStandardCompare($1.item.name) == .orderedAscending
        }
        .map(\.item)
    }
}
