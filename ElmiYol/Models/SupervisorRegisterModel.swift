//
//  SupervisorRegisterModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import Foundation

struct SupervisorRegisterModel {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var workplace = ""
    var position = ""
    var academicDegree = ""
    var specialityField = ""
    var password = ""
    var confirmPassword = ""
    var acceptedTerms = false

    var workplaceId = ""
    var facultyId = ""
    var faculty = ""
    var specialityId = ""
    
    var isComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty &&
        !workplace.isEmpty && !position.isEmpty && !academicDegree.isEmpty && !specialityField.isEmpty &&
        (password.isEmpty || password == confirmPassword) && acceptedTerms
    }
}
