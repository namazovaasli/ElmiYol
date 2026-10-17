//
//  CatalogModels.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.10.26.
//

import Foundation

struct CatalogItem: Identifiable, Hashable {
    let id: String
    let name: String
}

struct PublicProfile: Identifiable, Hashable {
    let id: String          
    let role: UserRole
    let firstName: String
    let lastName: String
    let universityId: String
    let university: String
    let faculty: String
    let speciality: String
    let position: String
    let academicDegree: String

    var fullName: String { "\(firstName) \(lastName)" }
}
