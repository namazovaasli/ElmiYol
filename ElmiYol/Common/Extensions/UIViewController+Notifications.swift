//
//  UIViewController+Notifications.swift
//  ElmiYol
//
// Created by Əsli Namazova on 19.07.26.
//

import UIKit

enum NotificationsOrigin: Int {
    case home = 0
    case research = 1
    case meetings = 2
    case messages = 3
    case profile = 4
}

extension UIViewController {

    func pushNotificationsScreen(from origin: NotificationsOrigin) {
        let notificationsVC = NotificationsViewController()
        notificationsVC.previousRoute = origin
        notificationsVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(notificationsVC)
    }
}
