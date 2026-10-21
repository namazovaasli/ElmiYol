//
//  ChatDetailViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit
import FirebaseAuth
import FirebaseFirestore
import SafariServices
import UniformTypeIdentifiers


final class ChatDetailViewController: UIViewController {

    private let otherUid: String?
    private let personName: String
    private let personSubtitle: String
    private var messages: [ChatMessageDoc] = []
    private var listener: ListenerRegistration?
    private var chatId = ""

    init(otherUid: String? = nil, personName: String, personSubtitle: String) {
        self.otherUid = otherUid
        self.personName = personName
        self.personSubtitle = personSubtitle
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.primary
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let headerContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        return view
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.reuseIdentifier)
        tv.separatorStyle = .none
        tv.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        tv.keyboardDismissMode = .interactive
        return tv
    }()

    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 6
        return view
    }()

    private let inputTextField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "Mesaj yazın...",
            attributes: [.foregroundColor: UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1)]
        )
        field.font = .systemFont(ofSize: 15, weight: .regular)
        field.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1)
        field.layer.cornerRadius = 20
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 40))
        field.leftView = paddingView
        field.leftViewMode = .always
        return field
    }()

    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = AppColors.primary
        button.tintColor = .white
        button.setImage(UIImage(systemName: "arrow.up"), for: .normal)
        button.layer.cornerRadius = 20
        return button
    }()
    private let attachButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.primary
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        return button
    }()
    
    private var didNavigate = false
    private var inputContainerBottomConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupConstraints()
        setupActions()
        startChat()
        registerKeyboardNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToBottom(animated: false)
    }
    deinit {
        listener?.remove()
        NotificationCenter.default.removeObserver(self)
    }

    private func startChat() {
        nameLabel.text = personName
        subtitleLabel.text = personSubtitle

        guard let me = Auth.auth().currentUser?.uid, let other = otherUid else {
            inputTextField.isEnabled = false
            inputTextField.placeholder = "Mesajlar bölməsindən istifadəçi seçin"
            attachButton.isEnabled = false
            sendButton.isEnabled = false
            return
        }

        chatId = ChatRepository.chatId(me, other)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await ChatRepository.shared.ensureChat(
                    chatId: chatId, me: me, other: other,
                    myName: UserSession.shared.displayFullName, otherName: personName
                )
                listener = ChatRepository.shared.listenMessages(chatId: chatId) { [weak self] items in
                    guard let self else { return }
                    self.messages = items
                    self.tableView.reloadData()
                    self.scrollToBottom(animated: false)
                    Task { await ChatRepository.shared.markRead(chatId: self.chatId, me: me) }
                }
            } catch {
                presentAuthMessage(error.localizedDescription, title: "Xəta")
            }
        }
    }

    private func setBusy(_ busy: Bool) {
        sendButton.isEnabled = !busy
        attachButton.isEnabled = !busy
        sendButton.alpha = busy ? 0.5 : 1
    }

    private func handleSendTap() {
        guard let me = Auth.auth().currentUser?.uid, let other = otherUid else { return }
        let text = (inputTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputTextField.text = ""

        Task {
            do {
                try await ChatRepository.shared.send(chatId: chatId, me: me, other: other, text: text)
            } catch {
                inputTextField.text = text
                presentAuthMessage(error.localizedDescription, title: "Mesaj göndərilmədi")
            }
        }
    }

    private func handleAttachTap() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.allowsMultipleSelection = false
        picker.delegate = self
        present(picker, animated: true)
    }

    private func sendFile(_ url: URL) async {
        guard let me = Auth.auth().currentUser?.uid, let other = otherUid else { return }
        setBusy(true)
        defer { setBusy(false) }
        do {
            let uploaded = try await SupabaseStorageService.shared.upload(localURL: url, folder: "chats/\(chatId)")
            try await ChatRepository.shared.send(
                chatId: chatId, me: me, other: other,
                kind: .file, filePath: uploaded.path, fileName: uploaded.name
            )
        } catch {
            presentAuthMessage(error.localizedDescription, title: "Fayl göndərilmədi")
        }
    }

    private func setupView() {
        view.addSubview(headerContainerView)
        headerContainerView.addSubview(backButton)
        headerContainerView.addSubview(avatarImageView)
        headerContainerView.addSubview(nameLabel)
        headerContainerView.addSubview(subtitleLabel)

        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(inputTextField)
        inputContainerView.addSubview(sendButton)
        inputContainerView.addSubview(attachButton)
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func setupConstraints() {
        headerContainerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-12)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.leading.equalTo(backButton.snp.trailing).offset(10)
            make.width.height.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.top).offset(-2)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-16)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().offset(-16)
        }

        avatarImageView.layer.cornerRadius = 20

        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainerView.snp.top)
        }

        inputContainerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            inputContainerBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).constraint
            make.height.equalTo(56)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }

        attachButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalTo(sendButton)
            make.width.height.equalTo(32)
        }

        inputTextField.snp.makeConstraints { make in
            make.leading.equalTo(attachButton.snp.trailing).offset(6)
            make.trailing.equalTo(sendButton.snp.leading).offset(-10)
            make.centerY.equalTo(sendButton)
            make.height.equalTo(40)
        }
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        sendButton.addAction(UIAction { [weak self] _ in
            self?.handleSendTap()
        }, for: .touchUpInside)
        
        attachButton.addAction(UIAction { [weak self] _ in
            self?.handleAttachTap()
        }, for: .touchUpInside)
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }


    private func scrollToBottom(animated: Bool) {
        guard !messages.isEmpty else { return }
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardOverlap = frame.height - view.safeAreaInsets.bottom
        inputContainerBottomConstraint?.update(offset: -keyboardOverlap)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom(animated: true)
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        inputContainerBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.reuseIdentifier, for: indexPath) as? ChatBubbleCell else {
            return UITableViewCell()
        }
        cell.configure(with: messages[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let message = messages[indexPath.row]
        guard message.kind == .file, let path = message.filePath else { return }
        Task {
            do {
                let url = try await SupabaseStorageService.shared.signedURL(path: path)
                present(SFSafariViewController(url: url), animated: true)
            } catch {
                presentAuthMessage("Faylı açmaq mümkün olmadı.", title: "Xəta")
            }
        }
    }
}

final class ChatBubbleCell: UITableViewCell {

    static let reuseIdentifier = "ChatBubbleCell"

    private let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        return label
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .regular)
        return label
    }()

    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        bubbleView.addSubview(timeLabel)

        bubbleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().offset(-4)
            make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
            leadingConstraint = make.leading.equalToSuperview().offset(16).constraint
            trailingConstraint = make.trailing.equalToSuperview().offset(-16).constraint
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(4)
            make.leading.equalTo(messageLabel)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: ChatMessageDoc) {
        messageLabel.text = message.kind == .file ? "📎 \(message.fileName ?? "Fayl")" : message.text
        timeLabel.text = message.timeText

        leadingConstraint?.deactivate()
        trailingConstraint?.deactivate()

        if message.isMine {
            bubbleView.backgroundColor = AppColors.primary
            messageLabel.textColor = .white
            timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
                make.trailing.equalToSuperview().offset(-16)
            }
        } else {
            bubbleView.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)
            messageLabel.textColor = AppColors.textPrimary
            timeLabel.textColor = AppColors.textSecondary
            bubbleView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(4)
                make.bottom.equalToSuperview().offset(-4)
                make.width.lessThanOrEqualToSuperview().multipliedBy(0.75)
                make.leading.equalToSuperview().offset(16)
            }
        }
    }
}

extension ChatDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        Task { await sendFile(url) }
    }
}
