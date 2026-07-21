//
//  AppRouter.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

protocol AppRouterProtocol: AnyObject {
    func push(_ route: Route, animated: Bool)
    func pop(animated: Bool)
    func setRoot(_ route: Route, in window: UIWindow?)
}
