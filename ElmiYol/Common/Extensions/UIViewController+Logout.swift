//
//  UIViewController+Logout.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import GoogleSignIn

extension UIViewController {

    func presentLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Çıxış",
            message: "Hesabınızdan çıxmaq istədiyinizə əminsiniz?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Çıxış", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        present(alert, animated: true)
    }

    func performLogout() {
        do {
            try FirebaseAuthService.shared.signOut()
            GIDSignIn.sharedInstance.signOut()
        } catch {
            presentAuthError(error)
            return
        }
        UserSession.shared.logout()
    }

    func handleProfileSettingsRowTap(_ title: String) {
        switch title {
        case "Bildiriş parametrləri":
            let settingsVC = SettingsViewController()
            settingsVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewControllerWithFade(settingsVC)
        case "Təhlükəsizlik":
            let privacyVC = PrivacySecurityViewController()
            privacyVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewControllerWithFade(privacyVC)
        case "Kömək və dəstək":
            let helpVC = HelpSupportViewController()
            helpVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewControllerWithFade(helpVC)
        case "Çıxış":
            presentLogoutConfirmation()
        default:
            break
        }
    }
}
