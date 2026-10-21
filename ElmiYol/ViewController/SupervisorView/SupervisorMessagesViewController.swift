//
//  SupervisorMessagesViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import SwiftUI
import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore

final class SupervisorMessagesViewController: UIViewController {

    private var didNavigate = false
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
    private let newMessageButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString("Yeni mesaj", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        button.configuration = config
        return button
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tələbələrinizlə mesajlaşın və əlaqədə qalın."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private let threadsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        headerView.delegate = self
        setupView()
        setupConstraints()
        loadThreads()
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
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(threadsStackView)
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
            make.leading.trailing.equalToSuperview().inset(20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        threadsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
        contentView.addSubview(newMessageButton)
        newMessageButton.addAction(UIAction { [weak self] _ in
            self?.handleNewMessageTap()
        }, for: .touchUpInside)
        
        newMessageButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        
    }

    deinit { listener?.remove() }

    private func loadThreads() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        listener = ChatRepository.shared.listenThreads(for: uid) { [weak self] threads in
            guard let self else { return }
            self.threadsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            for thread in threads {
                let row = self.makeThreadRow(name: thread.otherName, preview: thread.lastMessage, time: thread.timeText, isOnline: false)
                row.onTap = { [weak self] in
                    guard let self, !self.didNavigate else { return }
                    self.didNavigate = true
                    self.openChat(uid: thread.otherUid, name: thread.otherName)
                }
                self.threadsStackView.addArrangedSubview(row)
            }
        }
    }

    private func openChat(uid: String, name: String) {
        let chatVC = ChatDetailViewController(otherUid: uid, personName: name, personSubtitle: "Magistr tələbəsi")
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(chatVC)
    }

    private func handleNewMessageTap() {
        var pickerHost: UIHostingController<PeoplePickerView>?
        let picker = PeoplePickerView { [weak self] person in
            pickerHost?.dismiss(animated: true) {
                self?.openChat(uid: person.uid, name: person.name)
            }
        }
        let host = UIHostingController(rootView: picker)
        pickerHost = host
        present(host, animated: true)
    }

    private func makeThreadRow(name: String, preview: String, time: String, isOnline: Bool) -> ThreadRowView {
        let row = ThreadRowView()
        let avatar = UIView()
        avatar.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        avatar.layer.cornerRadius = 26
        let icon = UIImageView(image: UIImage(systemName: "person.fill"))
        icon.tintColor = AppColors.primary
        avatar.addSubview(icon)
        icon.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(22) }

        if isOnline {
            let dot = UIView()
            dot.backgroundColor = AppColors.green
            dot.layer.cornerRadius = 6
            dot.layer.borderWidth = 2
            dot.layer.borderColor = UIColor.white.cgColor
            avatar.addSubview(dot)
            dot.snp.makeConstraints { make in
                make.bottom.trailing.equalToSuperview()
                make.width.height.equalTo(12)
            }
        }

        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = AppColors.textPrimary

        let previewLabel = UILabel()
        previewLabel.text = preview
        previewLabel.font = .systemFont(ofSize: 13)
        previewLabel.textColor = AppColors.textSecondary

        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = AppColors.textMuted

        row.addSubview(avatar)
        row.addSubview(nameLabel)
        row.addSubview(previewLabel)
        row.addSubview(timeLabel)

        avatar.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(14)
            make.width.height.equalTo(52)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar)
            make.trailing.equalToSuperview()
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar)
            make.leading.equalTo(avatar.snp.trailing).offset(12)
        }
        previewLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview()
        }

        let separator = UIView()
        separator.backgroundColor = AppColors.separator
        row.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return row
    }
}

private final class ThreadRowView: UIView {
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func handleTap() {
        onTap?()
    }
}

extension SupervisorMessagesViewController: SideMenuViewControllerDelegate {
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

extension SupervisorMessagesViewController: TabScreenHeaderViewDelegate {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView) {
        presentSideMenu(current: .messages, delegate: self)
    }

    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView) {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .messages)
    }
}
