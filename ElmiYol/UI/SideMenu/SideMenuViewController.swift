//
//  SideMenuViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 20.07.26.
//

import UIKit
import SnapKit

enum SideMenuItem: Int, CaseIterable {
    case home
    case research
    case meetings
    case messages
    case notifications
    case profile
    case settings
    case help
    case privacy

    var title: String {
        switch self {
        case .home: return "Ana səhifə"
        case .research: return "Tədqiqatlarım"
        case .meetings: return "Görüşlər"
        case .messages: return "Mesajlar"
        case .notifications: return "Bildirişlər"
        case .profile: return "Profil"
        case .settings: return "Parametrlər"
        case .help: return "Kömək və dəstək"
        case .privacy: return "Gizlilik və təhlükəsizlik"
        }
    }

    var iconSystemName: String {
        switch self {
        case .home: return "house.fill"
        case .research: return "folder.fill"
        case .meetings: return "calendar"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .notifications: return "bell.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        case .help: return "questionmark.circle.fill"
        case .privacy: return "checkmark.shield.fill"
        }
    }

    
    var hasSeparatorAfter: Bool {
        switch self {
        case .profile: return true
        default: return false
        }
    }

    var badgeCount: Int? {
        switch self {
        case .messages: return UserSession.shared.unreadMessagesCount
        case .notifications: return UserSession.shared.unreadNotificationsCount
        default: return nil
        }
    }

    var tabIndex: Int? {
        switch self {
        case .home: return 0
        case .research: return 1
        case .meetings: return 2
        case .messages: return 3
        case .profile: return 4
        default: return nil
        }
    }
}

protocol SideMenuViewControllerDelegate: AnyObject {
    func sideMenu(_ menu: SideMenuViewController, didSelectTabAt index: Int)
    func sideMenuDidSelectNotifications(_ menu: SideMenuViewController)
    func sideMenuDidSelectSettings(_ menu: SideMenuViewController)
    func sideMenuDidSelectHelp(_ menu: SideMenuViewController)
    func sideMenuDidSelectPrivacy(_ menu: SideMenuViewController)
    func sideMenuDidSelectLogout(_ menu: SideMenuViewController)
}

final class SideMenuViewController: UIViewController {

    weak var delegate: SideMenuViewControllerDelegate?

    var currentItem: SideMenuItem = .home {
        didSet { menuRows.forEach { $0.setSelected($0.item == currentItem) } }
    }

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        view.alpha = 0
        return view
    }()

    private let panelView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    private let headerView = UIView()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "elmiyol_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let logoTitleLabel: UILabel = {
        let label = UILabel()
        let text = "ElmiYol"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: AppColors.textPrimary
            ]
        )
        if let range = text.range(of: "Yol") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.foregroundColor, value: AppColors.primary, range: nsRange)
        }
        label.attributedText = attributed
        return label
    }()

    private let logoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.textPrimary
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        return button
    }()

    private let userCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = AppColors.separator.cgColor
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.applyAvatarPlaceholder()
        return iv
    }()

    private let onlineDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.75, blue: 0.4, alpha: 1)
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 1
        return label
    }()

    private let roleBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        view.layer.cornerRadius = 10
        return view
    }()

    private let roleIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = AppColors.primary
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let itemsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }()

    private let logoutRow = SideMenuRowView(
        item: nil,
        overrideTitle: "Çıxış",
        overrideIcon: "rectangle.portrait.and.arrow.right",
        overrideTint: AppColors.badgeRed
    )

    private let footerCardView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.tintBlue
        view.layer.cornerRadius = 14
        return view
    }()

    private let footerIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "info.circle.fill")
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "ElmiYol v1.0.0"
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let copyrightLabel: UILabel = {
        let label = UILabel()
        label.text = "© 2026 Bütün hüquqlar qorunur."
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let panelWidthRatio: CGFloat = 0.85
    private let panelMaxWidth: CGFloat = 340

    private var menuRows: [SideMenuRowView] = []
    private var separatorViews: [UIView] = []

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupView()
        setupConstraints()
        setupActions()
        configureUserInfo()
        menuRows.forEach { $0.setSelected($0.item == currentItem) }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIn()
        avatarImageView.refreshAvatar()
    }

    private func setupView() {
        view.addSubview(dimmingView)
        view.addSubview(panelView)

        panelView.addSubview(scrollView)

        logoStack.addArrangedSubview(logoImageView)
        logoStack.addArrangedSubview(logoTitleLabel)

        scrollView.addSubview(headerView)
        headerView.addSubview(logoStack)
        headerView.addSubview(closeButton)

        scrollView.addSubview(userCardView)
        userCardView.addSubview(avatarImageView)
        avatarImageView.addSubview(onlineDotView)
        userCardView.addSubview(nameLabel)
        roleBadgeView.addSubview(roleIconImageView)
        roleBadgeView.addSubview(roleLabel)
        userCardView.addSubview(roleBadgeView)
        userCardView.addSubview(emailLabel)

        scrollView.addSubview(itemsStackView)

        for item in SideMenuItem.allCases {
            let row = SideMenuRowView(item: item)
            itemsStackView.addArrangedSubview(row)
            menuRows.append(row)

            if item.hasSeparatorAfter {
                let separator = UIView()
                separator.backgroundColor = AppColors.separator
                separator.snp.makeConstraints { $0.height.equalTo(1) }
                itemsStackView.addArrangedSubview(separator)
                separatorViews.append(separator)
            }
        }

        itemsStackView.addArrangedSubview(logoutRow)

        scrollView.addSubview(footerCardView)
        footerCardView.addSubview(footerIconImageView)
        footerCardView.addSubview(versionLabel)
        footerCardView.addSubview(copyrightLabel)
    }

    private func setupConstraints() {
        dimmingView.snp.makeConstraints { $0.edges.equalToSuperview() }

        panelView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-panelMaxWidth)
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(panelWidthRatio)
            make.width.lessThanOrEqualTo(panelMaxWidth)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.top).offset(56)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        logoStack.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(32)
        }

        closeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(logoStack)
            make.width.height.equalTo(28)
        }

        userCardView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(56)
        }

        onlineDotView.snp.makeConstraints { make in
            make.bottom.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(14)
            make.trailing.equalToSuperview().offset(-16)
        }

        roleBadgeView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.height.equalTo(22)
        }

        roleIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }

        roleLabel.snp.makeConstraints { make in
            make.leading.equalTo(roleIconImageView.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }

        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(roleBadgeView.snp.bottom).offset(8)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }

        itemsStackView.snp.makeConstraints { make in
            make.top.equalTo(userCardView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        for row in menuRows {
            row.snp.makeConstraints { $0.height.equalTo(48) }
        }

        logoutRow.snp.makeConstraints { $0.height.equalTo(48) }

        for separator in separatorViews {
            separator.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(8)
            }
        }

        footerCardView.snp.makeConstraints { make in
            make.top.equalTo(itemsStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(scrollView.snp.bottom).offset(-16)
        }

        footerIconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        versionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(footerIconImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
        }

        copyrightLabel.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(2)
            make.leading.equalTo(versionLabel)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func setupActions() {
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(handleDimTap))
        dimmingView.addGestureRecognizer(dimTap)
        dimmingView.isUserInteractionEnabled = true

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleDimTap))
        swipeLeft.direction = .left
        panelView.addGestureRecognizer(swipeLeft)

        closeButton.addAction(UIAction { [weak self] _ in
            self?.animateOutAndDismiss()
        }, for: .touchUpInside)

        for row in menuRows {
            guard let item = row.item else { continue }
            row.onTap = { [weak self] in
                self?.handleItemTap(item)
            }
        }

        logoutRow.onTap = { [weak self] in
            self?.handleLogoutTap()
        }
    }

    private func configureUserInfo() {
        let fullName = UserSession.shared.displayFullName
        nameLabel.text = fullName.isEmpty ? "İstifadəçi" : fullName

        switch UserSession.shared.currentRole {
        case .student:
            roleLabel.text = "Magistr tələbəsi"
            roleIconImageView.image = UIImage(systemName: "graduationcap.fill")
        case .supervisor:
            roleLabel.text = "Elmi rəhbər"
            roleIconImageView.image = UIImage(systemName: "person.fill")
        case .none:
            roleLabel.text = ""
        }

        emailLabel.text = UserSession.shared.displayEmail

        for row in menuRows {
            row.updateBadge(row.item?.badgeCount)
        }
    }

    @objc private func handleDimTap() {
        animateOutAndDismiss()
    }

    private func handleItemTap(_ item: SideMenuItem) {
        switch item {
        case .settings:
            animateOutAndDismiss { [weak self] in
                guard let self else { return }
                self.delegate?.sideMenuDidSelectSettings(self)
            }
        case .help:
            animateOutAndDismiss { [weak self] in
                guard let self else { return }
                self.delegate?.sideMenuDidSelectHelp(self)
            }
        case .privacy:
            animateOutAndDismiss { [weak self] in
                guard let self else { return }
                self.delegate?.sideMenuDidSelectPrivacy(self)
            }
        case .notifications:
            animateOutAndDismiss { [weak self] in
                guard let self else { return }
                self.delegate?.sideMenuDidSelectNotifications(self)
            }
        default:
            guard let index = item.tabIndex else {
                animateOutAndDismiss()
                return
            }
            animateOutAndDismiss { [weak self] in
                guard let self else { return }
                self.delegate?.sideMenu(self, didSelectTabAt: index)
            }
        }
    }

    private func handleLogoutTap() {
        animateOutAndDismiss { [weak self] in
            guard let self else { return }
            self.delegate?.sideMenuDidSelectLogout(self)
        }
    }

    private func animateIn() {
        panelView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(0)
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
            self.dimmingView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func animateOutAndDismiss(completion: (() -> Void)? = nil) {
        panelView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(-panelMaxWidth)
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseIn]) {
            self.dimmingView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false, completion: completion)
        }
    }
}

private final class SideMenuRowView: UIView {

    let item: SideMenuItem?
    var onTap: (() -> Void)?

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let selectionBackground = UIView()
    private let badgeView = UIView()
    private let badgeLabel = UILabel()
    private let tint: UIColor

    init(item: SideMenuItem?, overrideTitle: String? = nil, overrideIcon: String? = nil, overrideTint: UIColor? = nil) {
        self.item = item
        self.tint = overrideTint ?? AppColors.primary
        super.init(frame: .zero)
        setup(title: overrideTitle ?? item?.title ?? "", icon: overrideIcon ?? item?.iconSystemName ?? "")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String, icon: String) {
        selectionBackground.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        selectionBackground.layer.cornerRadius = 12
        selectionBackground.alpha = 0

        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = tint
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = AppColors.textPrimary

        badgeView.backgroundColor = AppColors.badgeRed
        badgeView.layer.cornerRadius = 10
        badgeView.isHidden = true

        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center

        addSubview(selectionBackground)
        addSubview(iconImageView)
        addSubview(titleLabel)
        badgeView.addSubview(badgeLabel)
        addSubview(badgeView)

        selectionBackground.snp.makeConstraints { $0.edges.equalToSuperview() }

        iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(14)
            make.trailing.lessThanOrEqualTo(badgeView.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        badgeView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        badgeLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.6
        }, completion: { _ in
            self.alpha = 1
            self.onTap?()
        })
    }

    func setSelected(_ selected: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.selectionBackground.alpha = selected ? 1 : 0
        }
        titleLabel.textColor = selected ? AppColors.primary : AppColors.textPrimary
        titleLabel.font = .systemFont(ofSize: 15, weight: selected ? .bold : .semibold)
        iconImageView.tintColor = selected ? AppColors.primary : tint
    }

    func updateBadge(_ count: Int?) {
        guard let count, count > 0 else {
            badgeView.isHidden = true
            return
        }
        badgeView.isHidden = false
        badgeLabel.text = "\(count)"
    }
}
