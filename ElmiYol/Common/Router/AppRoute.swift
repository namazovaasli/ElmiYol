//
//  AppRoute.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

protocol AppRoute {
    func viewController() -> UIViewController
}

enum Route: AppRoute {
    case splash
        case onboardingFirst
        case onboardingSecond
        case roleSelection
        case studentRegister
        case supervisorRegister
        case login
        case studentMainTabBar
        case supervisorMainTabBar
        case notifications
    
    
    func viewController() -> UIViewController {
           switch self {
           case .splash:
               return SplashViewController()
           case .onboardingFirst:
               return OnboardingFirstViewController()
           case .onboardingSecond:
               return OnboardingSecondViewController()
           case .roleSelection:
               return RoleSelectionViewController()
           case .studentRegister:
               return StudentRegisterViewController()
           case .supervisorRegister:
               return SupervisorRegisterViewController()
           case .login:
               return LoginViewController()
           case .studentMainTabBar:
               let tabBar = MainTabBarController()
               tabBar.roleContext = .student
               return tabBar
           case .supervisorMainTabBar:
               let tabBar = MainTabBarController()
               tabBar.roleContext = .supervisor
               return tabBar
           case .notifications:
               return NotificationsViewController()
           }
       }
   }
