//
//  UIImageView+Avatar.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 23.10.26.
//

import UIKit

extension UIImageView {
    func applyAvatarPlaceholder() {
        clipsToBounds = true
        backgroundColor = AppColors.tintBlue
        refreshAvatar()
        NotificationCenter.default.addObserver(forName: .avatarChanged, object: nil, queue: .main) { [weak self] _ in
            self?.refreshAvatar()
        }
    }

    func refreshAvatar() {
        if let photo = AvatarStore.shared.image {
            image = photo
            contentMode = .scaleAspectFill
        } else if let asset = UIImage(named: "user_avatar") {
            image = asset
            contentMode = .scaleAspectFill
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
            image = UIImage(systemName: "person.fill", withConfiguration: config)
            tintColor = AppColors.primary
            contentMode = .center
        }
    }
}
