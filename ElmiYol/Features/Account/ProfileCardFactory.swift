//
//  ProfileCardFactory.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 28.10.26.
//

import SnapKit
import UIKit

enum ProfileCardFactory {
    static func make(roleTitle: String,
                     onEdit: @escaping () -> Void,
                     onPhoto: @escaping (UIView) -> Void) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColors.surface
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12

        let avatar = UIImageView()
        avatar.layer.cornerRadius = 36
        avatar.applyAvatarPlaceholder()
        avatar.isUserInteractionEnabled = true

        let cameraBadge = UIImageView(image: UIImage(systemName: "camera.fill"))
        cameraBadge.tintColor = .white
        cameraBadge.contentMode = .center
        cameraBadge.backgroundColor = AppColors.primary
        cameraBadge.layer.cornerRadius = 12
        cameraBadge.layer.borderWidth = 2
        cameraBadge.layer.borderColor = UIColor.white.cgColor

        let name = UserSession.shared.displayFullName
        let nameLabel = UILabel()
        nameLabel.text = name.isEmpty ? "İstifadəçi" : name
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = AppColors.textPrimary
        nameLabel.numberOfLines = 2

        let roleBadge = UILabel()
        roleBadge.text = "  \(roleTitle)  "
        roleBadge.font = .systemFont(ofSize: 12, weight: .medium)
        roleBadge.textColor = AppColors.primary
        roleBadge.backgroundColor = AppColors.tintBlue
        roleBadge.layer.cornerRadius = 10
        roleBadge.clipsToBounds = true

        let emailLabel = UILabel()
        emailLabel.text = "✉ \(UserSession.shared.displayEmail)"
        emailLabel.font = .systemFont(ofSize: 13)
        emailLabel.textColor = AppColors.textSecondary
        emailLabel.adjustsFontSizeToFitWidth = true
        emailLabel.minimumScaleFactor = 0.8

        let phoneLabel = UILabel()
        phoneLabel.text = "📞 \(UserSession.shared.displayPhone)"
        phoneLabel.font = .systemFont(ofSize: 13)
        phoneLabel.textColor = AppColors.textSecondary

        let editButton = UIButton(type: .system)
        var config = UIButton.Configuration.tinted()
        config.image = UIImage(systemName: "pencil")
        config.imagePadding = 6
        config.cornerStyle = .large
        config.title = "Redaktə et"
        config.baseForegroundColor = AppColors.primary
        config.baseBackgroundColor = AppColors.primary
        editButton.configuration = config
        editButton.addAction(UIAction { _ in onEdit() }, for: .touchUpInside)

        avatar.addGestureRecognizer(PhotoTap(onPhoto: { onPhoto(avatar) }))

        [avatar, cameraBadge, nameLabel, roleBadge, emailLabel, phoneLabel, editButton].forEach { card.addSubview($0) }

        avatar.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(72)
        }
        cameraBadge.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(avatar).offset(4)
            make.width.height.equalTo(24)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar).offset(6)
            make.leading.equalTo(avatar.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-20)
        }
        roleBadge.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.height.equalTo(24)
        }
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        editButton.snp.makeConstraints { make in
            make.top.equalTo(phoneLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        return card
    }
}

private final class PhotoTap: UITapGestureRecognizer {
    private let onPhoto: () -> Void
    init(onPhoto: @escaping () -> Void) {
        self.onPhoto = onPhoto
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(fire))
    }
    @objc private func fire() { onPhoto() }
}
