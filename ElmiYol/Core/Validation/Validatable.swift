//
//  Validatable.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 16.07.26.
//

import Foundation

protocol Validatable {
    func validate(_ value: String) -> ValidationResult
}

enum ValidationResult {
    case valid
    case invalid(message: String)

    var isValid: Bool {
        switch self {
        case .valid: return true
        case .invalid: return false
        }
    }

    var errorMessage: String? {
        guard case .invalid(let message) = self else { return nil }
        return message
    }
}
