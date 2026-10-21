//
//  SupervisorHomeViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 17.07.26.
//


import UIKit
import SnapKit

final class SupervisorHomeViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()

    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

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
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )
        if let range = text.range(of: "Yol") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
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

    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let notificationBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.25, blue: 0.3, alpha: 1)
        view.layer.cornerRadius = 9
        return view
    }()

    private let notificationBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "3"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let greetingSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bugünkü işlərinizi asanlıqla idarə edin."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "user_avatar")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
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

    private let summaryCardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 24
        return view
    }()

    private let summaryGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor(red: 0.2, green: 0.42, blue: 0.95, alpha: 1).cgColor,
            UIColor(red: 0.1, green: 0.3, blue: 0.85, alpha: 1).cgColor
        ]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        return layer
    }()

    private let summaryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ümumi baxış"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let periodButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.18)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        config.attributedTitle = AttributedString("Bu həftə", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ]))
        button.configuration = config
        return button
    }()

    private lazy var statStudentsView = StatItemView(
        iconSystemName: "person.2.fill",
        iconTint: UIColor(red: 0.2, green: 0.42, blue: 0.95, alpha: 1),
        iconBackground: .white,
        value: "7",
        caption: "Tələbələrim"
    )

    private lazy var statResearchView = StatItemView(
        iconSystemName: "calendar",
        iconTint: UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1),
        iconBackground: UIColor(red: 0.24, green: 0.68, blue: 0.48, alpha: 1),
        value: "3",
        caption: "Aktiv tədqiqatlar"
    )

    private lazy var statMeetingView = StatItemView(
        iconSystemName: "bubble.left.fill",
        iconTint: UIColor(red: 0.5, green: 0.3, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.58, green: 0.4, blue: 0.9, alpha: 1),
        value: "5",
        caption: "Görüşlər"
    )

    private lazy var statNotificationView = StatItemView(
        iconSystemName: "bell.fill",
        iconTint: UIColor(red: 0.9, green: 0.6, blue: 0.15, alpha: 1),
        iconBackground: UIColor(red: 0.95, green: 0.68, blue: 0.25, alpha: 1),
        value: "2",
        caption: "Yeni bildiriş"
    )

    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()


    private let quickAccessCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let quickAccessTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sürətli giriş"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private lazy var studentsQuickView = QuickAccessItemView(
        iconSystemName: "person.2.fill",
        iconTint: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1),
        iconBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
        titleText: "Tələbələrim"
    )

    private lazy var researchQuickView = QuickAccessItemView(
        iconSystemName: "folder.fill",
        iconTint: UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1),
        iconBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        titleText: "Tədqiqatlar"
    )

    private lazy var meetingsQuickView = QuickAccessItemView(
        iconSystemName: "calendar",
        iconTint: UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
        titleText: "Görüşlər"
    )

    private lazy var messagesQuickView = QuickAccessItemView(
        iconSystemName: "bubble.left.and.bubble.right.fill",
        iconTint: UIColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1),
        iconBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
        titleText: "Mesajlar"
    )

    private lazy var reportsQuickView = QuickAccessItemView(
        iconSystemName: "doc.text.fill",
        iconTint: UIColor(red: 0.16, green: 0.5, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.88, green: 0.93, blue: 1, alpha: 1),
        titleText: "Hesabatlar"
    )

    private let quickAccessStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }()

    private let meetingsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private lazy var meetingsSectionHeaderView = SectionHeaderView(title: "Yaxın görüşlər")

    private lazy var advisorMeetingRow = SupervisorMeetingRowView(
        dateDay: "23",
        dateMonth: "May",
        dateYear: "2025",
        titleText: "Rəhbərlik görüşü",
        personText: "Əsli Namazova",
        timeText: "14:00",
        modeText: "Online (Zoom)",
        badgeText: "Sabah",
        badgeTint: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1),
        badgeBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
    )

    private lazy var planMeetingRow = SupervisorMeetingRowView(
        dateDay: "27",
        dateMonth: "May",
        dateYear: "2025",
        titleText: "Tədqiqat planı müzakirəsi",
        personText: "Nigar Əliyeva",
        timeText: "11:00",
        modeText: "Online (Google Meet)",
        badgeText: "3 gün sonra",
        badgeTint: UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1),
        badgeBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1)
    )

    private let meetingsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private let researchCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private lazy var researchSectionHeaderView = SectionHeaderView(title: "Aktiv tədqiqatlarım")

    private lazy var aiResearchRow = SupervisorResearchRowView(
        iconSystemName: "doc.text.fill",
        iconTint: UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1),
        iconBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        titleText: "Süni intellektin təhsildə tətbiqi imkanları",
        personText: "Əsli Namazova",
        progress: 0.65
    )

    private lazy var securityResearchRow = SupervisorResearchRowView(
        iconSystemName: "chart.xyaxis.line",
        iconTint: UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
        titleText: "Mobil tətbiqlərdə təhlükəsizlik yanaşmaları",
        personText: "Reşad Hüseynli",
        progress: 0.40
    )

    private let researchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()


    private let notificationsCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private lazy var notificationsSectionHeaderView = SectionHeaderView(title: "Son bildirişlər")

    private lazy var documentNotificationRow = NotificationRowView(
        iconSystemName: "bell.fill",
        iconTint: UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
        messageText: "Əsli Namazova tərəfindən yeni sənəd əlavə edildi.",
        timeText: "2 saat əvvəl"
    )

    private lazy var messageNotificationRow = NotificationRowView(
        iconSystemName: "bubble.left.fill",
        iconTint: UIColor(red: 0.16, green: 0.6, blue: 0.4, alpha: 1),
        iconBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        messageText: "Nigar Əliyeva sizə mesaj göndərdi.",
        timeText: "5 saat əvvəl"
    )

    private let notificationsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        setupView()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        updateGreeting()
    }
    private func updateGreeting() {
        let firstName = UserSession.shared.displayFirstName
        greetingLabel.text = "Xoş gəldiniz, \(firstName)! 👋"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        summaryGradientLayer.frame = summaryCardView.bounds
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        logoStack.addArrangedSubview(logoImageView)
        logoStack.addArrangedSubview(logoTitleLabel)

        contentView.addSubview(menuButton)
        contentView.addSubview(logoStack)
        contentView.addSubview(notificationButton)
        notificationButton.addSubview(notificationBadgeView)
        notificationBadgeView.addSubview(notificationBadgeLabel)

        contentView.addSubview(greetingLabel)
        contentView.addSubview(greetingSubtitleLabel)
        contentView.addSubview(avatarImageView)
        avatarImageView.addSubview(onlineDotView)

        summaryCardView.layer.insertSublayer(summaryGradientLayer, at: 0)
        contentView.addSubview(summaryCardView)
        summaryCardView.addSubview(summaryTitleLabel)
        summaryCardView.addSubview(periodButton)

        statsStackView.addArrangedSubview(statStudentsView)
        statsStackView.addArrangedSubview(statResearchView)
        statsStackView.addArrangedSubview(statMeetingView)
        statsStackView.addArrangedSubview(statNotificationView)
        summaryCardView.addSubview(statsStackView)

        contentView.addSubview(quickAccessCardView)
        quickAccessCardView.addSubview(quickAccessTitleLabel)

        quickAccessStackView.addArrangedSubview(studentsQuickView)
        quickAccessStackView.addArrangedSubview(researchQuickView)
        quickAccessStackView.addArrangedSubview(meetingsQuickView)
        quickAccessStackView.addArrangedSubview(messagesQuickView)
        quickAccessStackView.addArrangedSubview(reportsQuickView)
        quickAccessCardView.addSubview(quickAccessStackView)

        contentView.addSubview(meetingsCardView)
        meetingsCardView.addSubview(meetingsSectionHeaderView)
        meetingsStackView.addArrangedSubview(advisorMeetingRow)
        meetingsStackView.addArrangedSubview(planMeetingRow)
        meetingsCardView.addSubview(meetingsStackView)

        contentView.addSubview(researchCardView)
        researchCardView.addSubview(researchSectionHeaderView)
        researchStackView.addArrangedSubview(aiResearchRow)
        researchStackView.addArrangedSubview(securityResearchRow)
        researchCardView.addSubview(researchStackView)

        contentView.addSubview(notificationsCardView)
        notificationsCardView.addSubview(notificationsSectionHeaderView)
        notificationsStackView.addArrangedSubview(documentNotificationRow)
        notificationsStackView.addArrangedSubview(messageNotificationRow)
        notificationsCardView.addSubview(notificationsStackView)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        logoStack.snp.makeConstraints { make in
            make.centerY.equalTo(menuButton)
            make.centerX.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(menuButton)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(48)
        }

        notificationBadgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-2)
            make.trailing.equalToSuperview().offset(2)
            make.width.height.equalTo(18)
        }

        notificationBadgeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(menuButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalTo(greetingLabel).offset(8)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(56)
        }

        onlineDotView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        greetingSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(20)
            make.trailing.lessThanOrEqualTo(avatarImageView.snp.leading).offset(-12)
        }

        summaryCardView.snp.makeConstraints { make in
            make.top.equalTo(greetingSubtitleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        summaryTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
        }

        periodButton.snp.makeConstraints { make in
            make.centerY.equalTo(summaryTitleLabel)
            make.trailing.equalToSuperview().offset(-24)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(summaryTitleLabel.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-28)
        }

        quickAccessCardView.snp.makeConstraints { make in
            make.top.equalTo(summaryCardView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        quickAccessTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
        }

        quickAccessStackView.snp.makeConstraints { make in
            make.top.equalTo(quickAccessTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }

        meetingsCardView.snp.makeConstraints { make in
            make.top.equalTo(quickAccessCardView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        meetingsSectionHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        meetingsStackView.snp.makeConstraints { make in
            make.top.equalTo(meetingsSectionHeaderView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-8)
        }

        researchCardView.snp.makeConstraints { make in
            make.top.equalTo(meetingsCardView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        researchSectionHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        researchStackView.snp.makeConstraints { make in
            make.top.equalTo(researchSectionHeaderView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-8)
        }

        notificationsCardView.snp.makeConstraints { make in
            make.top.equalTo(researchCardView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-24)
        }

        notificationsSectionHeaderView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        notificationsStackView.snp.makeConstraints { make in
            make.top.equalTo(notificationsSectionHeaderView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    private func setupActions() {
        menuButton.addAction(UIAction { [weak self] _ in
            self?.handleMenuTap()
        }, for: .touchUpInside)

        notificationButton.addAction(UIAction { [weak self] _ in
            self?.handleNotificationsTap()
        }, for: .touchUpInside)

        meetingsSectionHeaderView.onSeeAllTapped = { [weak self] in
            self?.selectTab(2)
        }

        researchSectionHeaderView.onSeeAllTapped = { [weak self] in
            self?.selectTab(1)
        }

        notificationsSectionHeaderView.onSeeAllTapped = { [weak self] in
            self?.selectTab(3)
        }

        studentsQuickView.onTap = { [weak self] in self?.selectTab(1) }
        researchQuickView.onTap = { [weak self] in self?.selectTab(1) }
        meetingsQuickView.onTap = { [weak self] in self?.selectTab(2) }
        messagesQuickView.onTap = { [weak self] in self?.selectTab(3) }
        reportsQuickView.onTap = { [weak self] in self?.selectTab(1) }

        advisorMeetingRow.onTap = { [weak self] in self?.selectTab(2) }
        planMeetingRow.onTap = { [weak self] in self?.selectTab(2) }

        aiResearchRow.onTap = { [weak self] in self?.selectTab(1) }
        securityResearchRow.onTap = { [weak self] in self?.selectTab(1) }

        documentNotificationRow.onTap = { [weak self] in self?.selectTab(3) }
        messageNotificationRow.onTap = { [weak self] in self?.selectTab(3) }
    }

    private func handleMenuTap() {
        presentSideMenu(current: .home, delegate: self)
    }
    private func handleNotificationsTap() {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .home)
    }
    
    private func selectTab(_ index: Int) {
        tabBarController?.selectedIndex = index
    }
}

extension SupervisorHomeViewController: SideMenuViewControllerDelegate {
    func sideMenu(_ menu: SideMenuViewController, didSelectTabAt index: Int) {
        tabBarController?.selectedIndex = index
    }

    func sideMenuDidSelectNotifications(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let notificationsVC = NotificationsViewController()
        notificationsVC.previousRoute = .home
        navigationController?.pushViewControllerWithFade(notificationsVC)
    }

    func sideMenuDidSelectSettings(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let settingsVC = SettingsViewController()
        navigationController?.pushViewControllerWithFade(settingsVC)
    }

    func sideMenuDidSelectHelp(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let helpVC = HelpSupportViewController()
        navigationController?.pushViewControllerWithFade(helpVC)
    }

    func sideMenuDidSelectPrivacy(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let privacyVC = PrivacySecurityViewController()
        navigationController?.pushViewControllerWithFade(privacyVC)
    }
    func sideMenuDidSelectLogout(_ menu: SideMenuViewController) {
        presentLogoutConfirmation()
    }
}

private final class StatItemView: UIView {

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        return label
    }()
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.numberOfLines = 0
        return label
    }()

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, value: String, caption: String) {
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 12
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        valueLabel.text = value
        captionLabel.text = caption

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(valueLabel)
        addSubview(captionLabel)

        iconContainerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(38)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(17)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }

        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private final class QuickAccessItemView: UIView {

    var onTap: (() -> Void)?

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, titleText: String) {
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 16
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        titleLabel.text = titleText

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTap() {
        onTap?()
    }
}


private final class SectionHeaderView: UIView {

    var onSeeAllTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.contentInsets = .zero
        button.configuration = config
        button.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        return button
    }()

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        var config = seeAllButton.configuration
        config?.attributedTitle = AttributedString("Hamısına bax", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config?.baseForegroundColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        seeAllButton.configuration = config

        addSubview(titleLabel)
        addSubview(seeAllButton)

        titleLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        seeAllButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        seeAllButton.addAction(UIAction { [weak self] _ in
            self?.onSeeAllTapped?()
        }, for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private final class SupervisorMeetingRowView: UIView {

    var onTap: (() -> Void)?

    private let dateCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        view.layer.cornerRadius = 14
        return view
    }()
    private let dateDayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    private let dateMonthYearLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()
    private let personLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()
    private let timeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "clock")
        iv.tintColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()
    private let modeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "video.fill")
        iv.tintColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let modeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()
    private let badgeView = UIView()
    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1)
        return view
    }()

    init(dateDay: String, dateMonth: String, dateYear: String, titleText: String, personText: String, timeText: String, modeText: String, badgeText: String, badgeTint: UIColor, badgeBackground: UIColor) {
        super.init(frame: .zero)

        dateDayLabel.text = dateDay
        dateMonthYearLabel.text = "\(dateMonth)\n\(dateYear)"
        titleLabel.text = titleText
        personLabel.text = personText
        timeLabel.text = timeText
        modeLabel.text = modeText
        badgeLabel.text = badgeText
        badgeLabel.textColor = badgeTint
        badgeView.backgroundColor = badgeBackground
        badgeView.layer.cornerRadius = 12

        setupHierarchy()
        setupConstraints()

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(dateCardView)
        dateCardView.addSubview(dateDayLabel)
        dateCardView.addSubview(dateMonthYearLabel)
        addSubview(titleLabel)
        addSubview(personLabel)
        addSubview(timeIconImageView)
        addSubview(timeLabel)
        addSubview(modeIconImageView)
        addSubview(modeLabel)
        badgeView.addSubview(badgeLabel)
        addSubview(badgeView)
        addSubview(chevronImageView)
        addSubview(separatorView)
    }

    private func setupConstraints() {
        dateCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview()
            make.width.equalTo(56)
            make.height.equalTo(56)
        }

        dateDayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview()
        }

        dateMonthYearLabel.snp.makeConstraints { make in
            make.top.equalTo(dateDayLabel.snp.bottom).offset(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-4)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(dateCardView)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        badgeView.snp.makeConstraints { make in
            make.centerY.equalTo(dateCardView)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            make.height.equalTo(26)
        }

        badgeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateCardView)
            make.leading.equalTo(dateCardView.snp.trailing).offset(12)
            make.trailing.equalTo(badgeView.snp.leading).offset(-8)
        }

        personLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        timeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(personLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.width.height.equalTo(12)
        }

        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeIconImageView)
            make.leading.equalTo(timeIconImageView.snp.trailing).offset(4)
        }

        modeIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(timeIconImageView)
            make.leading.equalTo(timeLabel.snp.trailing).offset(12)
            make.width.height.equalTo(12)
        }

        modeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeIconImageView)
            make.leading.equalTo(modeIconImageView.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview()
            make.bottom.equalToSuperview().offset(-14)
        }

        separatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    @objc private func didTap() {
        onTap?()
    }
}


private final class SupervisorResearchRowView: UIView {

    var onTap: (() -> Void)?

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.numberOfLines = 2
        return label
    }()
    private let personProgressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1)
        return view
    }()

    private let progressValue: CGFloat

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, titleText: String, personText: String, progress: CGFloat) {
        self.progressValue = progress
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 22
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        titleLabel.text = titleText
        personProgressLabel.text = "\(personText) • \(Int(progress * 100))% tamamlandı"
        progressPercentLabel.text = "\(Int(progress * 100))%"

        setupHierarchy()
        setupConstraints()

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(chevronImageView)
        addSubview(personProgressLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(progressPercentLabel)
        addSubview(separatorView)
    }

    private func setupConstraints() {
        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview()
            make.width.height.equalTo(44)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }

        personProgressLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(personProgressLabel).offset(20)
            make.trailing.equalToSuperview()
        }

        progressTrackView.snp.makeConstraints { make in
            make.top.equalTo(personProgressLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(progressPercentLabel.snp.leading).offset(-8)
            make.height.equalTo(8)
        }

        separatorView.snp.makeConstraints { make in
            make.top.equalTo(progressTrackView.snp.bottom).offset(14)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressFillView.frame = CGRect(
            x: 0, y: 0,
            width: progressTrackView.bounds.width * progressValue,
            height: progressTrackView.bounds.height
        )
    }

    @objc private func didTap() {
        onTap?()
    }
}


private final class NotificationRowView: UIView {

    var onTap: (() -> Void)?

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.numberOfLines = 2
        return label
    }()
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, messageText: String, timeText: String) {
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 18
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        messageLabel.text = messageText
        timeLabel.text = timeText

        setupHierarchy()
        setupConstraints()

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(timeLabel)
        addSubview(chevronImageView)
    }

    private func setupConstraints() {
        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview()
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(15)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(3)
            make.leading.equalTo(messageLabel)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    @objc private func didTap() {
        onTap?()
    }
}
