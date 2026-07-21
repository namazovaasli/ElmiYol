//
//  AppRouter.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 16.07.26.
//

import UIKit
import SnapKit

final class AppRouter: AppRouterProtocol {

    static let shared = AppRouter()

    weak var navigationController: UINavigationController?

    private init() {}

    func push(_ route: Route, animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        let vc = route.viewController()
        if animated {
            navigationController.pushViewControllerWithFade(vc)
        } else {
            navigationController.pushViewController(vc, animated: false)
        }
    }

    func pop(animated: Bool = true) {
        guard let navigationController = navigationController else { return }
        if animated {
            navigationController.popViewControllerWithFade()
        } else {
            navigationController.popViewController(animated: false)
        }
    }

    func setRoot(_ route: Route, in window: UIWindow?) {
        guard let window = window else { return }
        let vc = route.viewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        self.navigationController = nav
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.rootViewController = nav
        }
    }
}
