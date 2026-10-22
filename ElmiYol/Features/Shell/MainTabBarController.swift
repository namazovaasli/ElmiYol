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
        UnreadMessagesObserver.shared.start()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshMessagesBadge), name: .unreadMessagesChanged, object: nil)
        refreshMessagesBadge()
    }
    @objc private func refreshMessagesBadge() {
        let count = UserSession.shared.unreadMessagesCount
        guard let items = viewControllers, items.count > 3 else { return }
        items[3].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
        items[3].tabBarItem.badgeColor = AppColors.badgeRed
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTabs() {
        switch roleContext {
        case .student:
            viewControllers = [
                makeNav(root: StudentHomeViewController(), title: "Ana səhifə", image: "house", selectedImage: "house.fill"),
                makeNav(root: StudentResearchViewController(), title: "Tədqiqatlar", image: "folder", selectedImage: "folder.fill"),
                makeNav(root: StudentMeetingsViewController(), title: "Görüşlər", image: "calendar", selectedImage: "calendar"),
                makeNav(root: MessagesHostingController(), title: "Mesajlar", image: "bubble.left.and.bubble.right", selectedImage: "bubble.left.and.bubble.right.fill"),
                makeNav(root: StudentProfileViewController(), title: "Profil", image: "person", selectedImage: "person.fill")
            ]
        case .supervisor:
            viewControllers = [
                makeNav(root: SupervisorHomeViewController(), title: "Ana səhifə", image: "house", selectedImage: "house.fill"),
                makeNav(root: SupervisorResearchViewController(), title: "Tədqiqatlar", image: "folder", selectedImage: "folder.fill"),
                makeNav(root: SupervisorMeetingsViewController(), title: "Görüşlər", image: "calendar", selectedImage: "calendar"),
                makeNav(root: MessagesHostingController(), title: "Mesajlar", image: "bubble.left.and.bubble.right", selectedImage: "bubble.left.and.bubble.right.fill"),
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
        tabBar.scrollEdgeAppearance = appearance
    }
}

