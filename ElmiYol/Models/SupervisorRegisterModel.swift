//
//  SupervisorRegisterModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import Foundation

struct SupervisorRegisterModel {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phone: String = ""
    var workplace: String = ""
    var position: String = ""
    var academicDegree: String = ""
    var specialityField: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var acceptedTerms: Bool = false

    var isComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty &&
        !workplace.isEmpty && !position.isEmpty && !academicDegree.isEmpty && !specialityField.isEmpty &&
        !password.isEmpty && password == confirmPassword && acceptedTerms
    }
}
