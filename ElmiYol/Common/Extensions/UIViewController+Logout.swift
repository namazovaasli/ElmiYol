//
//  UIViewController+Logout.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit

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
        UserSession.shared.logout()

        guard let window = view.window ?? Self.activeKeyWindow else { return }

        window.rootViewController?.dismiss(animated: false)
        AppRouter.shared.setRoot(.roleSelection, in: window)
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

    private static var activeKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
