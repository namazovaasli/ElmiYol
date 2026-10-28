//
//  StudentHomeViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 17.07.26.
//

import UIKit
import SnapKit

final class StudentHomeViewController: UIViewController {
    
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
        label.text = "0"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let greetingSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bugünkü fəaliyyətinə nəzər sal."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.applyAvatarPlaceholder()
        return iv
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
        label.text = "Fəaliyyət icmalı"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .white
        return label
    }()

    private let summaryTrendDotView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()

    private lazy var statResearchView = StatItemView(
        iconSystemName: "doc.text.fill",
        iconTint: UIColor(red: 0.2, green: 0.42, blue: 0.95, alpha: 1),
        iconBackground: .white,
        value: "0",
        caption: "Aktiv tədqiqat"
    )

    private lazy var statMeetingView = StatItemView(
        iconSystemName: "calendar",
        iconTint: AppColors.green,
        iconBackground: UIColor(red: 0.24, green: 0.68, blue: 0.48, alpha: 1),
        value: "0",
        caption: "Görüş bu həftə"
    )

    private lazy var statNotificationView = StatItemView(
        iconSystemName: "bell.fill",
        iconTint: UIColor(red: 0.5, green: 0.3, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.58, green: 0.4, blue: 0.9, alpha: 1),
        value: "0",
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

    private let quickAccessDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.7, green: 0.8, blue: 0.95, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()

    private lazy var researchQuickView = QuickAccessItemView(
        iconSystemName: "folder.fill",
        iconTint: AppColors.primary,
        iconBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
        titleText: "Tədqiqatlarım"
    )

    private lazy var meetingsQuickView = QuickAccessItemView(
        iconSystemName: "person.2.fill",
        iconTint: UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1),
        iconBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
        titleText: "Görüşlər"
    )

    private lazy var messagesQuickView = QuickAccessItemView(
        iconSystemName: "bubble.left.and.bubble.right.fill",
        iconTint: AppColors.green,
        iconBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        titleText: "Mesajlar"
    )

    private lazy var newResearchQuickView = QuickAccessItemView(
        iconSystemName: "doc.badge.plus",
        iconTint: UIColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1),
        iconBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
        titleText: "Yeni tədqiqat"
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

    private lazy var meetingsSectionHeaderView = SectionHeaderView(title: "Növbəti görüşlərim")

   

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

    private let researchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        setupView()
        setupConstraints()
        setupActions()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handlePlannerChanged),
            name: .plannerChanged, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleNotificationsChanged),
            name: NotificationStore.didChange, object: nil)
        reloadFromPlanner()
        updateNotificationCounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        updateGreeting()
        reloadFromPlanner()
        updateNotificationCounts()
        avatarImageView.refreshAvatar()
    }
    @objc private func handlePlannerChanged() {
        reloadFromPlanner()
    }

    @objc private func handleNotificationsChanged() {
        updateNotificationCounts()
    }
    
    private func updateNotificationCounts() {
        let count = NotificationStore.shared.unreadCount
        notificationBadgeLabel.text = count > 99 ? "99+" : "\(count)"
        notificationBadgeView.isHidden = count == 0
        statNotificationView.setValue("\(count)")
    }

    private func reloadFromPlanner() {
        let store = PlannerStore.shared
        let me = store.myUid

        statResearchView.setValue("\(store.activeResearches.count)")
        statMeetingView.setValue("\(store.meetingsThisWeekCount)")

        meetingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let upcoming = Array(store.upcomingMeetings.prefix(2))
        if upcoming.isEmpty {
            meetingsStackView.addArrangedSubview(makeEmptyLabel("Planlaşdırılmış görüş yoxdur"))
        }
        for meeting in upcoming {
            let row = MeetingRowView(
                iconSystemName: "calendar",
                iconTint: AppColors.primary,
                iconBackground: AppColors.tintBlue,
                titleText: meeting.title,
                personText: meeting.otherName(for: me),
                dateText: Self.dateText(meeting.startsAt),
                timeText: Self.timeText(meeting.startsAt),
                badgeText: Self.relativeBadge(meeting.startsAt),
                badgeTint: AppColors.primary,
                badgeBackground: AppColors.tintBlue
            )
            row.onTap = { [weak self] in self?.openMeeting(meeting) }
            meetingsStackView.addArrangedSubview(row)
        }

        researchStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let active = Array(store.activeResearches.prefix(2))
        if active.isEmpty {
            researchStackView.addArrangedSubview(makeEmptyLabel("Aktiv tədqiqat yoxdur"))
        }
        for research in active {
            researchStackView.addArrangedSubview(
                ResearchProgressRowView(iconSystemName: "book.fill", titleText: research.title, progress: research.progress))
        }
    }

    private func openMeeting(_ meeting: Meeting) {
        guard !didNavigate else { return }
        didNavigate = true
        let status: String
        switch meeting.status {
        case "confirmed": status = "Təsdiqləndi"
        case "cancelled": status = "Ləğv edilib"
        default: status = "Gözləyir"
        }
        let data = MeetingDetailData(
            titleText: meeting.title,
            personText: meeting.otherName(for: PlannerStore.shared.myUid),
            dateText: Self.dateText(meeting.startsAt),
            timeText: "\(Self.timeText(meeting.startsAt)) – \(Self.timeText(meeting.endsAt))",
            modeText: meeting.mode,
            statusText: status,
            statusTint: AppColors.primary,
            statusBackground: AppColors.tintBlue
        )
        let detailVC = MeetingDetailViewController(data: data)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(detailVC)
    }

    private func makeEmptyLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textMuted
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "az")
        f.dateFormat = "d MMM yyyy"
        return f.string(from: date)
    }

    private static func timeText(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }

    private static func relativeBadge(_ date: Date) -> String {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: Date()),
                                           to: calendar.startOfDay(for: date)).day ?? 0
        switch days {
        case ...0: return "Bu gün"
        case 1: return "Sabah"
        default: return "\(days) gün sonra"
        }
    }
    private func updateGreeting() {
        let firstName = UserSession.shared.displayFirstName
        greetingLabel.text = "Xoş gəldin, \(firstName)! 👋"
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

        summaryCardView.layer.insertSublayer(summaryGradientLayer, at: 0)
        contentView.addSubview(summaryCardView)
        summaryCardView.addSubview(summaryTitleLabel)
        summaryCardView.addSubview(summaryTrendDotView)

        statsStackView.addArrangedSubview(statResearchView)
        statsStackView.addArrangedSubview(statMeetingView)
        statsStackView.addArrangedSubview(statNotificationView)
        summaryCardView.addSubview(statsStackView)

        contentView.addSubview(quickAccessCardView)
        quickAccessCardView.addSubview(quickAccessTitleLabel)
        quickAccessCardView.addSubview(quickAccessDotView)

        quickAccessStackView.addArrangedSubview(researchQuickView)
        quickAccessStackView.addArrangedSubview(meetingsQuickView)
        quickAccessStackView.addArrangedSubview(messagesQuickView)
        quickAccessStackView.addArrangedSubview(newResearchQuickView)
        quickAccessCardView.addSubview(quickAccessStackView)

        contentView.addSubview(meetingsCardView)
        meetingsCardView.addSubview(meetingsSectionHeaderView)
        meetingsCardView.addSubview(meetingsStackView)

        contentView.addSubview(researchCardView)
        researchCardView.addSubview(researchSectionHeaderView)
        researchCardView.addSubview(researchStackView)
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

        summaryTrendDotView.snp.makeConstraints { make in
            make.centerY.equalTo(summaryTitleLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(10)
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

        quickAccessDotView.snp.makeConstraints { make in
            make.centerY.equalTo(quickAccessTitleLabel)
            make.trailing.equalToSuperview().offset(-24)
            make.width.height.equalTo(10)
        }

        quickAccessStackView.snp.makeConstraints { make in
            make.top.equalTo(quickAccessTitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
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
            make.bottom.equalToSuperview().offset(-24)
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
            make.bottom.equalToSuperview().offset(-24)
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

        researchQuickView.onTap = { [weak self] in
            self?.selectTab(1)
        }
        meetingsQuickView.onTap = { [weak self] in
            self?.selectTab(2)
        }
        messagesQuickView.onTap = { [weak self] in
            self?.selectTab(3)
        }
        newResearchQuickView.onTap = { [weak self] in
            self?.selectTab(1)
        }
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
extension StudentHomeViewController: SideMenuViewControllerDelegate {}

private final class StatItemView: UIView {

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        return label
    }()
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.numberOfLines = 0
        return label
    }()

    func setValue(_ text: String) { valueLabel.text = text }
    
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
            make.width.height.equalTo(40)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(18)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(10)
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
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, titleText: String) {
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 18
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        titleLabel.text = titleText

        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
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
        button.tintColor = AppColors.primary
        return button
    }()

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
        var config = seeAllButton.configuration
        config?.attributedTitle = AttributedString("Hamısına bax", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config?.baseForegroundColor = AppColors.primary
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


private final class MeetingRowView: UIView {

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
        return label
    }()
    private let personLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()
    private let dateIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "calendar")
        iv.tintColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
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

    init(iconSystemName: String, iconTint: UIColor, iconBackground: UIColor, titleText: String, personText: String, dateText: String, timeText: String, badgeText: String, badgeTint: UIColor, badgeBackground: UIColor) {
        super.init(frame: .zero)

        iconContainerView.backgroundColor = iconBackground
        iconContainerView.layer.cornerRadius = 22
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = iconTint
        titleLabel.text = titleText
        personLabel.text = personText
        dateLabel.text = dateText
        timeLabel.text = timeText
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
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(personLabel)
        addSubview(dateIconImageView)
        addSubview(dateLabel)
        addSubview(timeIconImageView)
        addSubview(timeLabel)
        badgeView.addSubview(badgeLabel)
        addSubview(badgeView)
        addSubview(chevronImageView)
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

        badgeView.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
            make.height.equalTo(26)
        }

        badgeLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(badgeView.snp.leading).offset(-8)
        }

        personLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview()
        }

        dateIconImageView.snp.makeConstraints { make in
            make.top.equalTo(personLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.width.height.equalTo(12)
        }

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateIconImageView)
            make.leading.equalTo(dateIconImageView.snp.trailing).offset(4)
        }

        timeIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(dateIconImageView)
            make.leading.equalTo(dateLabel.snp.trailing).offset(12)
            make.width.height.equalTo(12)
        }

        timeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateIconImageView)
            make.leading.equalTo(timeIconImageView.snp.trailing).offset(4)
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


private final class ResearchProgressRowView: UIView {

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
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let progressCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "İrəliləyiş"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = 4
        return view
    }()
    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let progressValue: CGFloat
    init(iconSystemName: String, titleText: String, progress: CGFloat) {
        self.progressValue = progress
        super.init(frame: .zero)

        iconContainerView.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        iconContainerView.layer.cornerRadius = 22
        iconImageView.image = UIImage(systemName: iconSystemName)
        iconImageView.tintColor = AppColors.primary
        titleLabel.text = titleText
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
        addSubview(progressCaptionLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(progressPercentLabel)
    }

    private func setupConstraints() {
        iconContainerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
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

        progressCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(16)
            make.leading.equalToSuperview()
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressCaptionLabel)
            make.trailing.equalToSuperview()
        }

        progressTrackView.snp.makeConstraints { make in
            make.top.equalTo(progressCaptionLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(8)
            make.bottom.equalToSuperview()
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

