//
//  UIImageView+Avatar.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 23.10.26.
//

import UIKit

extension UIImageView {
    func applyAvatarPlaceholder() {
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        image = UIImage(systemName: "person.fill", withConfiguration: config)
        tintColor = AppColors.primary
        contentMode = .center
        clipsToBounds = true
        backgroundColor = AppColors.tintBlue
    }
}
