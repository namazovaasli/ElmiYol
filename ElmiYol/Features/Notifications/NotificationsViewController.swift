//
//  NotificationsViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

private enum NotificationFilter: Int {
    case all, unread, read, messages, research, meetings, system
}

private struct NotificationGroup {
    let title: String
    let items: [NotificationItem]
}

private struct NotificationItem {
    let id: String
    let kind: AppNotification.Kind
    let person: String
    let iconSystemName: String
    let iconTint: UIColor
    let iconBackground: UIColor
    let title: String
    let message: String
    let meta: String
    let time: String
    let isUnread: Bool
}

final class NotificationsViewController: UIViewController {

    var previousRoute: NotificationsOrigin = .home

    private var currentFilter: NotificationFilter = .all
    private var didNavigate = false
    private var allGroups: [NotificationGroup] = []
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.delaysContentTouches = false
        return sv
    }()
    private let contentView = UIView()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.primary
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = AppColors.cardShadow
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bildirişlər"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sistemdəki bütün bildirişlərin siyahısı."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "line.3.horizontal.decrease")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.attributedTitle = AttributedString("Filtr", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.baseForegroundColor = AppColors.primary
        config.background.strokeColor = AppColors.primary
        config.background.strokeWidth = 1
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        button.configuration = config
        return button
    }()

    private let filtersScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let filtersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        return stack
    }()

    private let notificationsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let markAllReadButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "checkmark.circle")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.attributedTitle = AttributedString("Bütün bildirişləri oxundu kimi işarələ", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.baseForegroundColor = AppColors.primary
        button.configuration = config
        return button
    }()

    private lazy var filterButtons: [(PillTabButton, NotificationFilter)] = [
        (PillTabButton(title: "Hamısı"), .all),
        (PillTabButton(title: "Oxunmamış"), .unread),
        (PillTabButton(title: "Tədqiqatlar"), .research),
        (PillTabButton(title: "Görüşlər"), .meetings),
        (PillTabButton(title: "Sistem"), .system)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupView()
        setupConstraints()
        setupActions()
        loadFromStore()
        updateFilters()
        reloadNotifications()
        NotificationCenter.default.addObserver(
            forName: NotificationStore.didChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.loadFromStore()
            self?.reloadNotifications()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            tabBarController?.tabBar.isHidden = false
        }
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(filterButton)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(filtersScrollView)
        filtersScrollView.addSubview(filtersStackView)
        contentView.addSubview(notificationsStackView)

        for (button, filter) in filterButtons {
            filtersStackView.addArrangedSubview(button)
            button.addAction(UIAction { [weak self] _ in
                self?.currentFilter = filter
                self?.updateFilters()
                self?.reloadNotifications()
            }, for: .touchUpInside)
        }

        let markAllButton = markAllReadButton
        contentView.addSubview(markAllButton)
        markAllButton.snp.makeConstraints { make in
            make.top.equalTo(notificationsStackView.snp.bottom).offset(20)
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

        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        filtersScrollView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }

        filtersStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.height.equalToSuperview()
        }

        notificationsStackView.snp.makeConstraints { make in
            make.top.equalTo(filtersScrollView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        filterButton.addAction(UIAction { [weak self] _ in
            self?.presentFilterSheet()
        }, for: .touchUpInside)

        markAllReadButton.addAction(UIAction { [weak self] _ in
            self?.markAllNotificationsRead()
        }, for: .touchUpInside)
    }

    private func presentFilterSheet() {
        let alert = UIAlertController(title: "Filtr", message: "Bildiriş kateqoriyasını seçin", preferredStyle: .actionSheet)
        let options: [(String, NotificationFilter)] = [
            ("Hamısı", .all),
            ("Oxunmamış", .unread),
            ("Oxunmuş", .read),
            ("Mesajlar", .messages),
            ("Tədqiqatlar", .research),
            ("Görüşlər", .meetings),
            ("Sistem", .system)
        ]
        for (title, filter) in options {
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.currentFilter = filter
                self?.updateFilters()
                self?.reloadNotifications()
            })
        }
        alert.addAction(UIAlertAction(title: "Oxunmuşları sil", style: .destructive) { _ in
            NotificationStore.shared.deleteAllRead()
        })
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
    }

    private func markAllNotificationsRead() {
        NotificationStore.shared.markAllRead()
        loadFromStore()
        reloadNotifications()
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        tabBarController?.selectedIndex = previousRoute.rawValue
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewControllerWithFade()
    }

    private func updateFilters() {
        for (button, filter) in filterButtons {
            button.setSelected(currentFilter == filter)
        }
    }

    private func reloadNotifications() {
        notificationsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let groups = filteredGroups()
        if groups.isEmpty {
            let empty = UILabel()
            empty.text = "Bildiriş yoxdur"
            empty.textAlignment = .center
            empty.font = .systemFont(ofSize: 14)
            empty.textColor = AppColors.textMuted
            notificationsStackView.addArrangedSubview(empty)
            return
        }

        for group in groups {
            let sectionLabel = UILabel()
            sectionLabel.text = group.title
            sectionLabel.font = .systemFont(ofSize: 16, weight: .bold)
            sectionLabel.textColor = AppColors.textPrimary
            notificationsStackView.addArrangedSubview(sectionLabel)

            for item in group.items {
                let row = NotificationCardRowView(item: item)
                row.onTap = { [weak self] in self?.handleNotificationTap(item) }
                row.onDelete = {
                    NotificationStore.shared.delete(id: item.id)
                }
                notificationsStackView.addArrangedSubview(row)
            }
        }
    }

    private func handleNotificationTap(_ item: NotificationItem) {
        if item.isUnread { NotificationStore.shared.markRead(id: item.id) }

        switch item.kind {
        case .system:
            return

        case .message:
            guard !didNavigate else { return }
            didNavigate = true
            tabBarController?.selectedIndex = NotificationsOrigin.messages.rawValue
            tabBarController?.tabBar.isHidden = false
            navigationController?.popViewControllerWithFade()

        case .meeting:
            guard !didNavigate else { return }
            didNavigate = true
            let data = MeetingDetailData(
                titleText: item.meta.isEmpty ? item.title : item.meta,
                personText: item.person,
                dateText: item.time,
                timeText: "—",
                modeText: "—",
                statusText: "Gözləyir",
                statusTint: AppColors.primary,
                statusBackground: AppColors.tintBlue
            )
            let detailVC = MeetingDetailViewController(data: data)
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewControllerWithFade(detailVC)

        case .research:
            guard !didNavigate else { return }
            didNavigate = true
            let researchItem = ResearchItem(
                id: item.id,
                iconSystemName: "doc.text.fill",
                iconTint: AppColors.primary,
                iconBackground: AppColors.tintBlue,
                statusText: "Aktiv",
                statusTint: AppColors.green,
                statusBackground: AppColors.tintGreen,
                titleText: item.meta.isEmpty ? item.title : item.meta,
                personText: item.person,
                startDateText: item.time,
                endDateText: "—",
                progress: 0
            )
            let detailVC = ResearchDetailViewController(item: researchItem)
            detailVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewControllerWithFade(detailVC)
        }
    }

    private func filteredGroups() -> [NotificationGroup] {
        guard currentFilter != .all else { return allGroups }

        return allGroups.compactMap { group in
            let filteredItems: [NotificationItem]
            switch currentFilter {
                case .unread:   filteredItems = group.items.filter { $0.isUnread }
                case .read:     filteredItems = group.items.filter { !$0.isUnread }
                case .messages: filteredItems = group.items.filter { $0.kind == .message }
                case .research: filteredItems = group.items.filter { $0.kind == .research }
                case .meetings: filteredItems = group.items.filter { $0.kind == .meeting }
                case .system:   filteredItems = group.items.filter { $0.kind == .system }
                case .all:      filteredItems = group.items
            }
            guard !filteredItems.isEmpty else { return nil }
            return NotificationGroup(title: group.title, items: filteredItems)
        }
    }

    private func loadFromStore() {
        func makeItem(_ n: AppNotification) -> NotificationItem {
            let style = Self.style(for: n.kind)
            return NotificationItem(
                id: n.id, kind: n.kind, person: n.person,
                iconSystemName: style.icon, iconTint: style.tint, iconBackground: style.background,
                title: n.title, message: n.message, meta: n.meta,
                time: Self.relativeTime(n.createdAt), isUnread: !n.isRead)
        }

        let all = NotificationStore.shared.allItems
        let unread = all.filter { !$0.isRead }.map(makeItem)
        let read = all.filter { $0.isRead }.map(makeItem)

        var groups: [NotificationGroup] = []
        if !unread.isEmpty { groups.append(NotificationGroup(title: "Oxunmamış", items: unread)) }
        if !read.isEmpty { groups.append(NotificationGroup(title: "Oxunmuş", items: read)) }
        allGroups = groups
    }

    private static func style(for kind: AppNotification.Kind) -> (icon: String, tint: UIColor, background: UIColor) {
        switch kind {
        case .message:  return ("message.fill", AppColors.primary, AppColors.tintBlue)
        case .meeting:  return ("calendar", AppColors.purple, AppColors.tintPurple)
        case .research: return ("doc.text.fill", AppColors.primary, AppColors.tintBlue)
        case .system:   return ("gearshape.fill", AppColors.orange, AppColors.tintOrange)
        }
    }

    private static func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "az")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }
}

private final class NotificationCardRowView: UIView {

    var onTap: (() -> Void)?
    var onDelete: (() -> Void)?

    init(item: NotificationItem) {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))

        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = AppColors.cardShadow
        containerView.layer.shadowOpacity = 0.04
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 8

        let iconContainerView = UIView()
        iconContainerView.backgroundColor = item.iconBackground
        iconContainerView.layer.cornerRadius = 18

        let iconImageView = UIImageView(image: UIImage(systemName: item.iconSystemName))
        iconImageView.tintColor = item.iconTint
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary

        let messageLabel = UILabel()
        messageLabel.text = item.message
        messageLabel.font = .systemFont(ofSize: 13)
        messageLabel.textColor = AppColors.textSecondary
        messageLabel.numberOfLines = 0

        let metaLabel = UILabel()
        metaLabel.text = item.meta.isEmpty ? nil : "📁 \(item.meta)"
        metaLabel.font = .systemFont(ofSize: 12)
        metaLabel.textColor = AppColors.textMuted

        let timeLabel = UILabel()
        timeLabel.text = item.time
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = AppColors.textMuted

        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(metaLabel)
        containerView.addSubview(timeLabel)

        if item.isUnread {
            let dot = UIView()
            dot.backgroundColor = AppColors.primary
            dot.layer.cornerRadius = 4
            containerView.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalTo(titleLabel)
                make.width.height.equalTo(8)
            }
        }
        else {
            let deleteButton = UIButton(type: .system)
            deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
            deleteButton.tintColor = AppColors.badgeRed
            deleteButton.addAction(UIAction { [weak self] _ in self?.onDelete?() }, for: .touchUpInside)
            containerView.addSubview(deleteButton)
            deleteButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-8)
                make.bottom.equalToSuperview().offset(-6)
                make.width.height.equalTo(32)
            }
        }

        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }

        iconContainerView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(14)
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-16)
        }

        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    @objc private func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
