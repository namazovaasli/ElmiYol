//
//  StudentRegisterModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import Foundation

struct StudentRegisterModel {
        var firstName: String = ""
        var lastName: String = ""
        var email: String = ""
        var phone: String = ""
        var university: String = ""
        var faculty: String = ""
        var speciality: String = ""
        var groupNumber: String = ""
        var studyYears: String = ""
        var password: String = ""
        var confirmPassword: String = ""
        var acceptedTerms: Bool = false

    var isComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !university.isEmpty && !faculty.isEmpty && !speciality.isEmpty && !groupNumber.isEmpty && !studyYears.isEmpty && (password.isEmpty || password == confirmPassword) && acceptedTerms
    }
}
