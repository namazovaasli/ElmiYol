//
//  UIViewController+SideMenu.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 20.07.26.
//

import UIKit

extension UIViewController {

    func presentSideMenu(current: SideMenuItem, delegate: SideMenuViewControllerDelegate) {
        let menu = SideMenuViewController()
        menu.currentItem = current
        menu.delegate = delegate
        present(menu, animated: false)
    }
}

extension SideMenuViewControllerDelegate where Self: UIViewController {

    func sideMenu(_ menu: SideMenuViewController, didSelectTabAt index: Int) {
        tabBarController?.selectedIndex = index
    }

    func sideMenuDidSelectLogout(_ menu: SideMenuViewController) {
        presentLogoutConfirmation()
    }
}
