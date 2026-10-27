//
//  AuthErrorMessage.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 23.10.26.
//

import FirebaseAuth
import Foundation

enum AuthErrorMessage {
    static func text(for error: Error) -> String? {
        if let own = error as? FirebaseAuthServiceError { return own.errorDescription }

        let ns = error as NSError

        if ns.domain == "com.google.GIDSignIn", ns.code == -5 { return nil }

        if ns.domain == "FIRAuthErrorDomain", let code = AuthErrorCode(rawValue: ns.code) {
            switch code {
            case .invalidEmail:
                return "E-poçt ünvanının formatı yanlışdır."
            case .emailAlreadyInUse:
                return "Bu e-poçt ünvanı ilə hesab artıq mövcuddur."
            case .weakPassword:
                return "Şifrə çox zəifdir. Ən azı 6 simvol istifadə edin."
            case .wrongPassword, .userNotFound, .invalidCredential:
                return "E-poçt və ya şifrə yanlışdır."
            case .userDisabled:
                return "Bu hesab deaktiv edilib."
            case .networkError:
                return "Şəbəkə bağlantısı yoxdur. İnterneti yoxlayıb yenidən cəhd edin."
            case .tooManyRequests:
                return "Çox sayda cəhd edildi. Bir az sonra yenidən yoxlayın."
            case .operationNotAllowed:
                return "Bu giriş üsulu hələ aktiv edilməyib."
            case .accountExistsWithDifferentCredential:
                return "Bu e-poçt başqa giriş üsulu ilə qeydiyyatdan keçib. Həmin üsulla daxil olun."
            default:
                return "Giriş alınmadı. Yenidən cəhd edin."
            }
        }

        if ns.domain == NSURLErrorDomain {
            return "Şəbəkə bağlantısı yoxdur. İnterneti yoxlayıb yenidən cəhd edin."
        }
        if let localized = error as? LocalizedError, let text = localized.errorDescription {
            return text
        }
        return "Xəta baş verdi. Bir az sonra yenidən cəhd edin."
    }
}
