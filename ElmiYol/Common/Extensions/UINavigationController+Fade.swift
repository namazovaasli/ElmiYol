//
//  UINavigationController+Fade.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

extension UINavigationController {
    func pushViewControllerWithFade(_ viewController: UIViewController, duration: CFTimeInterval = 0.35) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: kCATransition)
        pushViewController(viewController, animated: false)
    }

    func popViewControllerWithFade(duration: CFTimeInterval = 0.35) {
        let transition = CATransition()
        transition.duration = duration
        transition.type = .fade
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(transition, forKey: kCATransition)
        popViewController(animated: false)
    }
}
