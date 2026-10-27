//
//  CatalogViewModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import Combine
import Foundation

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published private(set) var universities: [CatalogItem] = []
    @Published private(set) var faculties: [CatalogItem] = []
    @Published private(set) var specialities: [CatalogItem] = []

    @Published private(set) var isLoadingUniversities = false
    @Published private(set) var isLoadingFaculties = false
    @Published private(set) var isLoadingSpecialities = false

    @Published private(set) var universitiesError: String?
    @Published private(set) var facultiesError: String?
    @Published private(set) var specialitiesError: String?

    private let repository: CatalogRepositoryProtocol
    private var facultiesRequest = 0
    private var specialitiesRequest = 0

    init() {
        self.repository = FirestoreCatalogRepository.shared
    }

    init(repository: CatalogRepositoryProtocol) {
        self.repository = repository
    }

    func loadUniversities() async {
        await Task.yield()
        guard universities.isEmpty, !isLoadingUniversities else { return }
        isLoadingUniversities = true
        universitiesError = nil
        defer { isLoadingUniversities = false }
        do {
            universities = try await repository.universities()
        } catch {
            universitiesError = Self.message(for: error)
        }
    }

    func loadFaculties(universityId: String) async {
        await Task.yield()
        facultiesRequest += 1
        let request = facultiesRequest
        faculties = []
        clearSpecialities()
        facultiesError = nil
        isLoadingFaculties = true
        do {
            let result = try await repository.faculties(universityId: universityId)
            guard request == facultiesRequest else { return }
            faculties = result
        } catch {
            guard request == facultiesRequest else { return }
            facultiesError = Self.message(for: error)
        }
        isLoadingFaculties = false
    }

    func loadSpecialities(universityId: String, facultyId: String) async {
        await Task.yield()
        specialitiesRequest += 1
        let request = specialitiesRequest
        specialities = []
        specialitiesError = nil
        isLoadingSpecialities = true
        do {
            let result = try await repository.specialities(universityId: universityId, facultyId: facultyId)
            guard request == specialitiesRequest else { return }
            specialities = result
        } catch {
            guard request == specialitiesRequest else { return }
            specialitiesError = Self.message(for: error)
        }
        isLoadingSpecialities = false
    }

    func clearFaculties() {
        facultiesRequest += 1
        faculties = []
        facultiesError = nil
        isLoadingFaculties = false
        clearSpecialities()
    }

    func clearSpecialities() {
        specialitiesRequest += 1
        specialities = []
        specialitiesError = nil
        isLoadingSpecialities = false
    }

    private static func message(for error: Error) -> String {
        if let serviceError = error as? FirebaseAuthServiceError,
           case .firebaseNotConfigured = serviceError {
            return "Firebase konfiqurasiyası tapılmadı."
        }
        return "Siyahını yükləmək mümkün olmadı. İnternet bağlantısını yoxlayıb yenidən cəhd edin."
    }
}
