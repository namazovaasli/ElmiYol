//
//  ElmiYolStyle.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 22.10.26.
//

import SwiftUI

enum ElmiYolStyle {
    static let background = Color(uiColor: AppColors.background)
    static let surface = Color(uiColor: AppColors.surface)
    static let primary = Color(uiColor: AppColors.primary)
    static let navy = Color(red: 0.09, green: 0.18, blue: 0.42)
    static let ink = Color(uiColor: AppColors.textPrimary)
    static let secondary = Color(uiColor: AppColors.textSecondary)
    static let muted = Color(uiColor: AppColors.textMuted)
    static let border = Color(uiColor: .dynamic(
        light: UIColor(red: 0.88, green: 0.9, blue: 0.94, alpha: 1),
        dark: UIColor(red: 0.2, green: 0.22, blue: 0.28, alpha: 1)))
}
