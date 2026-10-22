//
//  CatalogSeeder.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.10.26.
//

import FirebaseFirestore
import Foundation

private struct SeedUniversity: Decodable {
    let id: String
    let name: String
    let faculties: [SeedFaculty]
}

private struct SeedFaculty: Decodable {
    let id: String
    let name: String
    let specialities: [String]
}

enum CatalogSeeder {
    static func run() async {
        do {
            guard let url = Bundle.main.url(forResource: "universities", withExtension: "json") else {
                print("universities.json bundle-da tapılmadı")
                return
            }
            let data = try Data(contentsOf: url)
            let universities = try JSONDecoder().decode([SeedUniversity].self, from: data)
            let db = Firestore.firestore()

            for (uIndex, uni) in universities.enumerated() {
                let batch = db.batch()
                let uniRef = db.collection("universities").document(uni.id)
                batch.setData(["name": uni.name, "order": uIndex, "isActive": true], forDocument: uniRef)

                for (fIndex, fac) in uni.faculties.enumerated() {
                    let facRef = uniRef.collection("faculties").document(fac.id)
                    batch.setData(["name": fac.name, "order": fIndex, "isActive": true], forDocument: facRef)

                    for (sIndex, name) in fac.specialities.enumerated() {
                       
                        let specRef = facRef.collection("specialities").document(String(format: "s%02d", sIndex + 1))
                        batch.setData(["name": name, "order": sIndex, "isActive": true], forDocument: specRef)
                    }
                }
                try await batch.commit()
                print("\(uni.name)")
            }
            print("Kataloq yükləndi: \(universities.count) universitet")
        } catch {
            print("Seed xətası:", error)
        }
    }
}
