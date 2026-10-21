//
//  StudentRegisterModel.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//
import Foundation

struct StudentRegisterModel {
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var university = ""
    var faculty = ""
    var speciality = ""
    var groupNumber = ""
    var studyYears = ""
    var password = ""
    var confirmPassword = ""
    var acceptedTerms = false

    var universityId = ""
    var facultyId = ""
    var specialityId = ""

    var isComplete: Bool {
        !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !phone.isEmpty && !university.isEmpty && !faculty.isEmpty && !speciality.isEmpty && !groupNumber.isEmpty && !studyYears.isEmpty && (password.isEmpty || password == confirmPassword) && acceptedTerms
    }
}
