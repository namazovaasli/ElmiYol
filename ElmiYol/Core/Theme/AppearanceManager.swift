//
//  AppearanceManager.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 26.10.26.
//

import UIKit

enum AppAppearance: Int, CaseIterable {
    case system = 0, light, dark

    var style: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var title: String {
        switch self {
        case .system: return "Sistemə uyğun"
        case .light:  return "İşıqlı"
        case .dark:   return "Qaranlıq"
        }
    }
}

final class AppearanceManager {
    static let shared = AppearanceManager()
    private let key = "appearance.mode"
    private init() {}

    var mode: AppAppearance {
        get { AppAppearance(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .system }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
            apply()
        }
    }

    func apply() {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = mode.style
            }
        }
    }
}
