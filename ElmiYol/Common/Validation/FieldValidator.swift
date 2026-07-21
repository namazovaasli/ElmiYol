//
//  FieldValidator.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 16.07.26.
//

import Foundation

enum ValidatorType {
    case name
    case surname
    case email
    case phone
    case password
    case confirmPassword(originalPassword: () -> String)
    case required(fieldName: String)
}

struct FieldValidator: Validatable {
    let type: ValidatorType

    func validate(_ value: String) -> ValidationResult {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

        switch type {
        case .name:
            return Self.validateName(trimmed, fieldName: "Ad")
        case .surname:
            return Self.validateName(trimmed, fieldName: "Soyad")
        case .email:
            return Self.validateEmail(trimmed)
        case .phone:
            return Self.validatePhone(trimmed)
        case .password:
            return Self.validatePassword(trimmed)
        case .confirmPassword(let originalPassword):
            return Self.validateConfirmPassword(trimmed, original: originalPassword())
        case .required(let fieldName):
            if trimmed.isEmpty {
                return .invalid(message: "\(fieldName) boş ola bilməz")
            }
            return .valid
        }
    }

    private static func validateName(_ value: String, fieldName: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid(message: "\(fieldName) boş ola bilməz")
        }
        guard value.count >= 2 else {
            return .invalid(message: "\(fieldName) ən azı 2 simvol olmalıdır")
        }
        let pattern = "^[a-zA-ZəƏöÖüÜğĞşŞçÇıİI\\s-]+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalid(message: "Yoxlama xətası")
        }
        let range = NSRange(location: 0, length: value.utf16.count)
        guard regex.firstMatch(in: value, range: range) != nil else {
            return .invalid(message: "\(fieldName) yalnız hərflərdən ibarət olmalıdır")
        }
        return .valid
    }

    private static func validateEmail(_ value: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid(message: "E-poçt ünvanı boş ola bilməz")
        }
        let pattern = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalid(message: "Yoxlama xətası")
        }
        let range = NSRange(location: 0, length: value.utf16.count)
        guard regex.firstMatch(in: value, range: range) != nil else {
            return .invalid(message: "Düzgün e-poçt ünvanı daxil edin")
        }
        return .valid
    }

    private static func validatePhone(_ value: String) -> ValidationResult {
        let digitsOnly = value.filter { $0.isNumber }
        let localDigits = digitsOnly.hasPrefix("994") ? String(digitsOnly.dropFirst(3)) : digitsOnly

        guard !localDigits.isEmpty else {
            return .invalid(message: "Telefon nömrəsi boş ola bilməz")
        }
        guard localDigits.count == 9 else {
            return .invalid(message: "Telefon nömrəsi 9 rəqəmdən ibarət olmalıdır")
        }
        let pattern = "^(10|12|50|51|55|60|70|77|99)\\d{7}$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalid(message: "Yoxlama xətası")
        }
        let range = NSRange(location: 0, length: localDigits.utf16.count)
        guard regex.firstMatch(in: localDigits, range: range) != nil else {
            return .invalid(message: "Düzgün Azərbaycan operator kodu daxil edin (50, 51, 55, 70, 77, 99 və s.)")
        }
        return .valid
    }

    private static func validatePassword(_ value: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid(message: "Şifrə boş ola bilməz")
        }
        guard value.count >= 8 else {
            return .invalid(message: "Şifrə ən azı 8 simvol olmalıdır")
        }
        let pattern = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$"
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return .invalid(message: "Yoxlama xətası")
        }
        let range = NSRange(location: 0, length: value.utf16.count)
        guard regex.firstMatch(in: value, range: range) != nil else {
            return .invalid(message: "Şifrədə ən azı 1 böyük, 1 kiçik hərf və 1 rəqəm olmalıdır")
        }
        return .valid
    }

    private static func validateConfirmPassword(_ value: String, original: String) -> ValidationResult {
        guard !value.isEmpty else {
            return .invalid(message: "Şifrəni təkrar daxil edin")
        }
        guard value == original else {
            return .invalid(message: "Şifrələr uyğun gəlmir")
        }
        return .valid
    }
}
