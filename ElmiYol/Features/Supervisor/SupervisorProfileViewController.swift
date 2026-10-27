//
//  SupervisorProfileViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

final class SupervisorProfileViewController: UIViewController {

    private var didNavigate = false

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()
    private let headerView = TabScreenHeaderView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profil"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesab məlumatlarınızı görüntüləyin və idarə edin."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        headerView.delegate = self
        setupView()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)
        contentView.addSubview(headerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        let profileCard = makeProfileCard()
        contentView.addSubview(profileCard)

        let s = UserSession.shared.supervisorData
        let infoSection = makeInfoSection(
            title: "Əsas məlumatlar",
            rows: [
                ("briefcase.fill", "Vəzifə", s?.position ?? "—"),
                ("building.2.fill", "İş yeri", s?.workplace ?? "—"),
                ("books.vertical.fill", "Fakültə", s?.faculty ?? "—"),
                ("book.fill", "İxtisas sahəsi", s?.specialityField ?? "—"),
                ("graduationcap.fill", "Elmi dərəcə", s?.academicDegree ?? "—")
            ]
        )
        
        contentView.addSubview(infoSection)

        let statsSection = makeStatsSection()
        contentView.addSubview(statsSection)

        let settingsSection = makeSettingsSection()
        contentView.addSubview(settingsSection)

        let footer = UILabel()
        footer.text = "ElmiYol v1.0.0\n© 2026 Bütün hüquqlar qorunur."
        footer.font = .systemFont(ofSize: 12)
        footer.textColor = AppColors.textMuted
        footer.textAlignment = .center
        footer.numberOfLines = 0
        contentView.addSubview(footer)

        profileCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        infoSection.snp.makeConstraints { make in
            make.top.equalTo(profileCard.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        statsSection.snp.makeConstraints { make in
            make.top.equalTo(infoSection.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        settingsSection.snp.makeConstraints { make in
            make.top.equalTo(statsSection.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        footer.snp.makeConstraints { make in
            make.top.equalTo(settingsSection.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func makeProfileCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12

        let avatarView = UIView()
        avatarView.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        avatarView.layer.cornerRadius = 36
        let avatarIcon = UIImageView(image: UIImage(named: "user_avatar"))
        avatarIcon.tintColor = AppColors.primary
        avatarView.addSubview(avatarIcon)
        avatarIcon.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(28) }

        let onlineDot = UIView()
        onlineDot.backgroundColor = AppColors.green
        onlineDot.layer.cornerRadius = 7
        onlineDot.layer.borderWidth = 2
        onlineDot.layer.borderColor = UIColor.white.cgColor
        avatarView.addSubview(onlineDot)
        onlineDot.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let name = UserSession.shared.displayFullName.isEmpty ? "İstifadəçi" : UserSession.shared.displayFullName
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = AppColors.textPrimary

        let roleBadge = UILabel()
        roleBadge.text = "  Elmi rəhbər  "
        roleBadge.font = .systemFont(ofSize: 12, weight: .medium)
        roleBadge.textColor = AppColors.primary
        roleBadge.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
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
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "pencil")
        config.imagePlacement = .leading
        config.imagePadding = 4
        config.attributedTitle = AttributedString("Redaktə et", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold)
        ]))
        config.baseForegroundColor = AppColors.primary
        editButton.configuration = config
        editButton.addAction(UIAction { [weak self] _ in
            self?.handleEditProfileTap()
        }, for: .touchUpInside)
        
        card.addSubview(avatarView)
        card.addSubview(nameLabel)
        card.addSubview(roleBadge)
        card.addSubview(emailLabel)
        card.addSubview(phoneLabel)
        card.addSubview(editButton)
        
        avatarView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(72)
        }
        editButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView).offset(8)
            make.leading.equalTo(avatarView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-8)
        }
        roleBadge.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.height.equalTo(24)
        }
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        return card
    }
    private func handleEditProfileTap() {
        let alert = UIAlertController(
            title: "Profil redaktəsi",
            message: "Profil məlumatlarını redaktə etmək tezliklə mövcud olacaq.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }
    

    private func makeStatsSection() -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = "Statistika"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary
        container.addSubview(titleLabel)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        for (bg, value, caption) in [
            (UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1), "13", "Aktiv tədqiqat"),
            (UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1), "24", "Tamamlanmış"),
            (UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1), "7", "Rəhbərlik etdiyim magistrlər"),
            (UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1), "28", "Keçirilən görüş")
        ] {
            stack.addArrangedSubview(makeStatCard(background: bg, value: value, caption: caption))
        }
        container.addSubview(stack)
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(80)
        }
        return container
    }

    private func makeStatCard(background: UIColor, value: String, caption: String) -> UIView {
        let card = UIView()
        card.backgroundColor = background
        card.layer.cornerRadius = 14
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = AppColors.textPrimary
        valueLabel.textAlignment = .center
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .systemFont(ofSize: 9, weight: .medium)
        captionLabel.textColor = AppColors.textSecondary
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 2
        card.addSubview(valueLabel)
        card.addSubview(captionLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }
        return card
    }

    private func makeInfoSection(title: String, rows: [(String, String, String)], isSettings: Bool = false) -> UIView {
        let container = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12

        let stack = UIStackView()
        stack.axis = .vertical
        for row in rows {
            stack.addArrangedSubview(makeInfoRow(
                icon: row.0,
                title: row.1,
                value: row.2,
                onTap: isSettings && row.1 != "Dil" ? { [weak self] in
                    guard let self, !self.didNavigate else { return }
                    if row.1 == "Çıxış" {
                        self.presentLogoutConfirmation()
                        return
                    }
                    self.didNavigate = true
                    self.handleProfileSettingsRowTap(row.1)
                } : nil
            ))
        }

        container.addSubview(titleLabel)
        container.addSubview(card)
        card.addSubview(stack)
        titleLabel.snp.makeConstraints { $0.top.leading.equalToSuperview() }
        card.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        return container
    }

    private func makeSettingsSection() -> UIView {
        makeInfoSection(title: "Parametrlər", rows: [
            ("person.crop.circle.fill", "Hesab məlumatları", ""),
            ("bell.fill", "Bildiriş parametrləri", ""),
            ("lock.fill", "Təhlükəsizlik", ""),
            ("globe", "Dil", "Azərbaycan dili"),
            ("questionmark.circle.fill", "Kömək və dəstək", ""),
            ("rectangle.portrait.and.arrow.right", "Çıxış", "")
        ], isSettings: true)
    }

    private func makeInfoRow(icon: String, title: String, value: String, onTap: (() -> Void)? = nil) -> UIView {
        let row = UIView()
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = title == "Çıxış" ? AppColors.badgeRed : AppColors.primary
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = title == "Çıxış" ? AppColors.badgeRed : AppColors.textPrimary

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 13)
        valueLabel.textColor = AppColors.textMuted

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted

        row.addSubview(iconView)
        row.addSubview(titleLabel)
        if !value.isEmpty { row.addSubview(valueLabel) }
        if title != "Çıxış" { row.addSubview(chevron) }

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview().inset(14)
        }
        if !value.isEmpty {
            valueLabel.numberOfLines = 2
            valueLabel.textAlignment = .right
            valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
            valueLabel.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalTo(chevron.snp.leading).offset(-8)
                make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(12)
            }
        }
        if title != "Çıxış" {
            chevron.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(12)
            }
        }

        if let onTap {
            row.isUserInteractionEnabled = true
            let tapRow = SettingsTapRowView()
            tapRow.onTap = onTap
            row.addGestureRecognizer(UITapGestureRecognizer(target: tapRow, action: #selector(SettingsTapRowView.handleTap)))
            objc_setAssociatedObject(row, &SettingsTapRowView.associationKey, tapRow, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        return row
    }
}

private final class SettingsTapRowView: NSObject {
    static var associationKey: UInt8 = 0
    var onTap: (() -> Void)?

    @objc func handleTap() {
        onTap?()
    }
}

extension SupervisorProfileViewController: SideMenuViewControllerDelegate {}

extension SupervisorProfileViewController: TabScreenHeaderViewDelegate {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView) {
        presentSideMenu(current: .profile, delegate: self)
    }

    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView) {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .profile)
    }
}
