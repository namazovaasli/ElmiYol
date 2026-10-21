//
//  StudentMessagesViewController.swift
//  ElmiYol
//
// Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore


private struct MessageThreadItem {
    let otherUid: String
    let name: String
    let preview: String
    let time: String
    let unreadCount: Int
    let isOnline: Bool
    let avatarColor: UIColor
}

private enum MessageFilter: Int {
    case all
    case unread
    case starred
}

final class StudentMessagesViewController: UIViewController {

    private var currentFilter: MessageFilter = .all
    private var didNavigate = false
    private var allThreads: [MessageThreadItem] = []
    private var listener: ListenerRegistration?

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.delaysContentTouches = false
        sv.canCancelContentTouches = true
        return sv
    }()
    private let contentView = UIView()

    private let headerView = TabScreenHeaderView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Mesajlar"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elmi rəhbəriniz və sistem üzərindən mesajlaşın."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private let newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString("Yeni mesaj", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        button.configuration = config
        return button
    }()

    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "Axtarış et..."
        field.font = .systemFont(ofSize: 15)
        field.backgroundColor = .white
        field.layer.cornerRadius = 14
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        return field
    }()

    private lazy var allFilterButton = PillTabButton(title: "Hamısı")
    private lazy var unreadFilterButton = PillTabButton(title: "Oxunmamış (2)")
    private lazy var starredFilterButton = PillTabButton(title: "Ulduzlu")

    private let filtersStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private let threadsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let infoBannerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        view.layer.cornerRadius = 14
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        headerView.delegate = self
        setupView()
        setupConstraints()
        setupActions()
        reloadThreads()
        startListening()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(newMessageButton)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(searchField)

        filtersStackView.addArrangedSubview(allFilterButton)
        filtersStackView.addArrangedSubview(unreadFilterButton)
        filtersStackView.addArrangedSubview(starredFilterButton)
        contentView.addSubview(filtersStackView)
        contentView.addSubview(threadsStackView)

        let infoIcon = UIImageView(image: UIImage(systemName: "envelope.fill"))
        infoIcon.tintColor = AppColors.primary
        let infoLabel = UILabel()
        infoLabel.text = "Mesajlara e-poçt üzərindən də cavab yaza bilərsiniz.\naslinamazova@bdu.edu.az"
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textColor = AppColors.textSecondary
        infoLabel.numberOfLines = 0

        infoBannerView.addSubview(infoIcon)
        infoBannerView.addSubview(infoLabel)
        contentView.addSubview(infoBannerView)

        infoIcon.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(14)
            make.width.height.equalTo(18)
        }
        infoLabel.snp.makeConstraints { make in
            make.leading.equalTo(infoIcon.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-14)
            make.top.bottom.equalToSuperview().inset(14)
        }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        newMessageButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        searchField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }

        filtersStackView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        threadsStackView.snp.makeConstraints { make in
            make.top.equalTo(filtersStackView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        infoBannerView.snp.makeConstraints { make in
            make.top.equalTo(threadsStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        allFilterButton.addAction(UIAction { [weak self] _ in
            self?.currentFilter = .all
            self?.updateFilters()
            self?.reloadThreads()
        }, for: .touchUpInside)

        unreadFilterButton.addAction(UIAction { [weak self] _ in
            self?.currentFilter = .unread
            self?.updateFilters()
            self?.reloadThreads()
        }, for: .touchUpInside)

        starredFilterButton.addAction(UIAction { [weak self] _ in
            self?.currentFilter = .starred
            self?.updateFilters()
            self?.reloadThreads()
        }, for: .touchUpInside)

        updateFilters()
    }

    deinit { listener?.remove() }

    private func startListening() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        listener = ChatRepository.shared.listenThreads(for: uid) { [weak self] threads in
            self?.allThreads = threads.map {
                MessageThreadItem(
                    otherUid: $0.otherUid,
                    name: $0.otherName,
                    preview: $0.lastMessage,
                    time: $0.timeText,
                    unreadCount: $0.unread,
                    isOnline: false,
                    avatarColor: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
                )
            }
            self?.reloadThreads()
        }
    }


    private func openChat(uid: String, name: String, subtitle: String) {
        let chatVC = ChatDetailViewController(otherUid: uid, personName: name, personSubtitle: subtitle)
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(chatVC)
    }

    private func updateFilters() {
        allFilterButton.setSelected(currentFilter == .all)
        unreadFilterButton.setSelected(currentFilter == .unread)
        starredFilterButton.setSelected(currentFilter == .starred)
    }

   

    private func reloadThreads() {
        threadsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [MessageThreadItem]
        switch currentFilter {
        case .all:
            items = allThreads
        case .unread:
            items = allThreads.filter { $0.unreadCount > 0 }
        case .starred:
            items = [allThreads.first].compactMap { $0 }
        }

        for item in items {
            let row = MessageThreadRowView(item: item)
            row.onTap = { [weak self] in
                guard let self, !self.didNavigate else { return }
                self.didNavigate = true
                self.openChat(uid: item.otherUid, name: item.name, subtitle: "Elmi rəhbər")
            }
            threadsStackView.addArrangedSubview(row)
        }
    }
}

extension StudentMessagesViewController: SideMenuViewControllerDelegate {
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
extension StudentMessagesViewController: TabScreenHeaderViewDelegate {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView) {
        presentSideMenu(current: .messages, delegate: self)
    }

    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView) {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .messages)
    }
}

private final class MessageThreadRowView: UIView {

    var onTap: (() -> Void)?

    init(item: MessageThreadItem) {
        super.init(frame: .zero)

        let avatarView = UIView()
        avatarView.backgroundColor = item.avatarColor
        avatarView.layer.cornerRadius = 26

        let avatarIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        avatarIcon.tintColor = AppColors.primary
        avatarView.addSubview(avatarIcon)
        avatarIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        if item.isOnline {
            let dot = UIView()
            dot.backgroundColor = AppColors.green
            dot.layer.cornerRadius = 6
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.white.cgColor
            avatarView.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview()
                make.width.height.equalTo(12)
            }
        }

        let nameLabel = UILabel()
        nameLabel.text = item.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = AppColors.textPrimary

        let previewLabel = UILabel()
        previewLabel.text = item.preview
        previewLabel.font = .systemFont(ofSize: 13)
        previewLabel.textColor = AppColors.textSecondary
        previewLabel.numberOfLines = 1

        let timeLabel = UILabel()
        timeLabel.text = item.time
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = AppColors.textMuted

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted

        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(previewLabel)
        addSubview(timeLabel)
        addSubview(chevron)

        if item.unreadCount > 0 {
            let badge = UILabel()
            badge.text = "\(item.unreadCount)"
            badge.font = .systemFont(ofSize: 11, weight: .bold)
            badge.textColor = .white
            badge.backgroundColor = AppColors.primary
            badge.textAlignment = .center
            badge.layer.cornerRadius = 10
            badge.clipsToBounds = true
            addSubview(badge)
            badge.snp.makeConstraints { make in
                make.centerY.equalTo(chevron)
                make.trailing.equalTo(chevron.snp.leading).offset(-8)
                make.width.height.equalTo(20)
            }
        }

        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(14)
            make.width.height.equalTo(52)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.trailing.equalToSuperview()
        }
        chevron.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.trailing.equalToSuperview()
            make.width.height.equalTo(14)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.leading.equalTo(avatarView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-8)
        }
        previewLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalTo(chevron.snp.leading).offset(-8)
        }

        let separator = UIView()
        separator.backgroundColor = AppColors.separator
        addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }

        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
