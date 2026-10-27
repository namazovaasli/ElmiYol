//
//  UIViewController+AuthFeedback.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit

extension UIViewController {
    func presentAuthError(_ error: Error) {
        guard let message = AuthErrorMessage.text(for: error) else { return }
        presentAuthMessage(message)
    }

    func presentAuthMessage(_ message: String, title: String = "Məlumat") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }
}
