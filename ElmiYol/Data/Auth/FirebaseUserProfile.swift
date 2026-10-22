//
//  FirebaseUserProfile.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import Foundation

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
            model.specialityField = value("specialityField")
            model.faculty = value("faculty")
            model.facultyId = value("facultyId")
            model.specialityId = value("specialityId")
            model.academicDegree = value("academicDegree")
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

