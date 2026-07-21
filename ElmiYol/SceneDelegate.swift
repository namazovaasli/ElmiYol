//
//  SceneDelegate.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 10.07.26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
           let window = UIWindow(windowScene: windowScene)
           self.window = window
           window.makeKeyAndVisible()
           AppRouter.shared.setRoot(.splash, in: window)
    }

   

}

