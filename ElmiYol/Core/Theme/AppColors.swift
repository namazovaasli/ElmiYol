//
//  AppColors.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit

extension UIColor {
    static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

enum AppColors {
    static let background = UIColor.dynamic(
        light: UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1),
        dark: UIColor(red: 0.05, green: 0.06, blue: 0.09, alpha: 1))
   
    static let surface = UIColor.dynamic(
        light: .white,
        dark: UIColor(red: 0.11, green: 0.12, blue: 0.16, alpha: 1))
    static let primary = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
    static let textPrimary = UIColor.dynamic(
        light: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1),
        dark: UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1))
    static let textSecondary = UIColor.dynamic(
        light: UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1),
        dark: UIColor(red: 0.62, green: 0.67, blue: 0.76, alpha: 1))
    static let textMuted = UIColor.dynamic(
        light: UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1),
        dark: UIColor(red: 0.52, green: 0.57, blue: 0.66, alpha: 1))
    static let badgeRed = UIColor(red: 0.95, green: 0.25, blue: 0.3, alpha: 1)
    static let separator = UIColor.dynamic(
        light: UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1),
        dark: UIColor(red: 0.18, green: 0.2, blue: 0.26, alpha: 1))
    static let cardShadow = UIColor.black.cgColor
    static let tabUnselected = textMuted
    static let green = UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1)
    static let orange = UIColor(red: 0.9, green: 0.6, blue: 0.15, alpha: 1)
    static let purple = UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1)

    static let tintBlue = UIColor.dynamic(
        light: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
        dark: UIColor(red: 0.12, green: 0.19, blue: 0.34, alpha: 1))
    static let tintGreen = UIColor.dynamic(
        light: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        dark: UIColor(red: 0.1, green: 0.24, blue: 0.18, alpha: 1))
    static let tintPurple = UIColor.dynamic(
        light: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
        dark: UIColor(red: 0.2, green: 0.15, blue: 0.34, alpha: 1))
    static let tintOrange = UIColor.dynamic(
        light: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
        dark: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1))
}
