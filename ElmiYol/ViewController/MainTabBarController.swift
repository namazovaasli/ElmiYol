//
//  MainTabBarController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class MainTabBarController: UITabBarController {

    enum UserRoleContext {
        case student
        case supervisor
    }

    var roleContext: UserRoleContext = .student

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        switch roleContext {
        case .student:
            viewControllers = [
                makeNav(root: StudentHomeViewController(), title: "Ana səhifə", image: "house", selectedImage: "house.fill"),
                makeNav(root: StudentResearchViewController(), title: "Tədqiqatlar", image: "folder", selectedImage: "folder.fill"),
                makeNav(root: StudentMeetingsViewController(), title: "Görüşlər", image: "calendar", selectedImage: "calendar"),
                makeNav(root: StudentMessagesViewController(), title: "Mesajlar", image: "bubble.left.and.bubble.right", selectedImage: "bubble.left.and.bubble.right.fill", badge: "2"),
                makeNav(root: StudentProfileViewController(), title: "Profil", image: "person", selectedImage: "person.fill")
            ]
        case .supervisor:
            viewControllers = [
                makeNav(root: SupervisorHomeViewController(), title: "Ana səhifə", image: "house", selectedImage: "house.fill"),
                makeNav(root: SupervisorResearchViewController(), title: "Tədqiqatlar", image: "folder", selectedImage: "folder.fill"),
                makeNav(root: SupervisorMeetingsViewController(), title: "Görüşlər", image: "calendar", selectedImage: "calendar"),
                makeNav(root: SupervisorMessagesViewController(), title: "Mesajlar", image: "bubble.left.and.bubble.right", selectedImage: "bubble.left.and.bubble.right.fill", badge: "2"),
                makeNav(root: SupervisorProfileViewController(), title: "Profil", image: "person", selectedImage: "person.fill")
            ]
        }
    }

    private func makeNav(
        root: UIViewController,
        title: String,
        image: String,
        selectedImage: String,
        badge: String? = nil
    ) -> UINavigationController {
        let nav = UINavigationController(rootViewController: root)
        nav.setNavigationBarHidden(true, animated: false)
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: UIImage(systemName: selectedImage)
        )
        if let badge {
            root.tabBarItem.badgeValue = badge
            root.tabBarItem.badgeColor = AppColors.badgeRed
        }
        return nav
    }

    private func setupAppearance() {
        tabBar.tintColor = AppColors.primary
        tabBar.unselectedItemTintColor = AppColors.tabUnselected

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = AppColors.separator

        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        itemAppearance.selected.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 11, weight: .medium)]
        appearance.stackedLayoutAppearance = itemAppearance

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

extension MainTabBarController: SideMenuViewControllerDelegate {
    func sideMenu(_ menu: SideMenuViewController, didSelectTabAt index: Int) {
        selectedIndex = index
    }

    func sideMenuDidSelectNotifications(_ menu: SideMenuViewController) {
        let notificationsVC = NotificationsViewController()
        notificationsVC.previousRoute = .home
        let nav = selectedViewController as? UINavigationController
        nav?.pushViewControllerWithFade(notificationsVC)
    }

    func sideMenuDidSelectSettings(_ menu: SideMenuViewController) {
        let settingsVC = SettingsViewController()
        let nav = selectedViewController as? UINavigationController
        nav?.pushViewControllerWithFade(settingsVC)
    }

    func sideMenuDidSelectHelp(_ menu: SideMenuViewController) {
        let helpVC = HelpSupportViewController()
        let nav = selectedViewController as? UINavigationController
        nav?.pushViewControllerWithFade(helpVC)
    }

    func sideMenuDidSelectPrivacy(_ menu: SideMenuViewController) {
        let privacyVC = PrivacySecurityViewController()
        let nav = selectedViewController as? UINavigationController
        nav?.pushViewControllerWithFade(privacyVC)
    }

    func sideMenuDidSelectLogout(_ menu: SideMenuViewController) {
        presentLogoutConfirmation()
    }
}
