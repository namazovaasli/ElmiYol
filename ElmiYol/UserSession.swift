//
//  UserSession.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import Foundation

final class UserSession {
    static let shared = UserSession()
    private init() {}

    var studentData: StudentRegisterModel?
    var supervisorData: SupervisorRegisterModel?
    var currentRole: UserRole?

    var displayFirstName: String {
        switch currentRole {
        case .student:
            return studentData?.firstName ?? "İstifadəçi"
        case .supervisor:
            return supervisorData?.firstName ?? "İstifadəçi"
        case .none:
            return "İstifadəçi"
        }
    }

    var displayFullName: String {
        switch currentRole {
        case .student:
            guard let data = studentData else { return "" }
            return "\(data.firstName) \(data.lastName)"
        case .supervisor:
            guard let data = supervisorData else { return "" }
            return "\(data.firstName) \(data.lastName)"
        case .none:
            return ""
        }
    }
}

extension UserSession {
    var displayEmail: String {
        switch currentRole {
        case .student: return studentData?.email ?? ""
        case .supervisor: return supervisorData?.email ?? ""
        case .none: return ""
        }
    }

    var unreadMessagesCount: Int { 2 }
    var unreadNotificationsCount: Int { 3 }

    func logout() {
        studentData = nil
        supervisorData = nil
        currentRole = nil
    }
}
