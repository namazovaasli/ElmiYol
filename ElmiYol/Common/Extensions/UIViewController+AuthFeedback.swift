import FirebaseAuth
import UIKit

extension UIViewController {
    func presentAuthError(_ error: Error) {
        let message: String
        if let configurationError = error as? FirebaseAuthServiceError {
            message = configurationError.localizedDescription
        } else if let authError = error as? NSError,
                  let code = AuthErrorCode(rawValue: authError.code) {
            switch code {
            case .invalidEmail:
                message = "E-poçt ünvanının formatı yanlışdır."
            case .emailAlreadyInUse:
                message = "Bu e-poçt ünvanı ilə hesab artıq mövcuddur."
            case .weakPassword:
                message = "Şifrə daha güclü olmalıdır."
            case .wrongPassword, .userNotFound, .invalidCredential:
                message = "E-poçt və ya şifrə yanlışdır."
            case .userDisabled:
                message = "Bu hesab deaktiv edilib."
            case .networkError:
                message = "Şəbəkə bağlantısını yoxlayıb yenidən cəhd edin."
            case .tooManyRequests:
                message = "Çox sayda cəhd edildi. Bir az sonra yenidən yoxlayın."
            case .operationNotAllowed:
                message = "Bu giriş üsulu Firebase layihəsində aktiv edilməyib."
            case .accountExistsWithDifferentCredential:
                message = "Bu e-poçt başqa giriş üsulu ilə qeydiyyatdan keçib. Həmin üsulla daxil olun."
            default:
                message = "Giriş zamanı xəta baş verdi. Yenidən cəhd edin."
            }
        } else {
            message = "Məlumatları yükləmək mümkün olmadı. İnternet bağlantısını yoxlayın."
        }
        presentAuthMessage(message)
    }

    func presentAuthMessage(_ message: String, title: String = "Məlumat") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }
}
