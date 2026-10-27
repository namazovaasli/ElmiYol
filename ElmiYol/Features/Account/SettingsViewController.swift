//
//  SettingsViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import FirebaseAuth
import FirebaseFirestore
import SnapKit
import UIKit
import UserNotifications

final class SettingsViewController: UIViewController {

    private enum Keys {
        static let push = "settings.push"
        static let email = "settings.email"
    }

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()
    private let backButton = BackButton()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Parametrlər"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tətbiq parametrlərini idarə edin."
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let appearanceValueLabel = UILabel()
    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupView()
        setupConstraints()
        backButton.addAction(UIAction { [weak self] _ in self?.handleBackTap() }, for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        appearanceValueLabel.text = AppearanceManager.shared.mode.title
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)
        [backButton, titleLabel, subtitleLabel].forEach { contentView.addSubview($0) }

        let pushOn = UserDefaults.standard.object(forKey: Keys.push) as? Bool ?? false
        let emailOn = UserDefaults.standard.object(forKey: Keys.email) as? Bool ?? true

        let generalCard = makeCard(rows: [
            makeSwitchRow(icon: "bell.fill", title: "Push bildirişləri", isOn: pushOn) { [weak self] on in
                self?.setPush(on)
            },
            makeSwitchRow(icon: "envelope.fill", title: "E-poçt bildirişləri", isOn: emailOn) { [weak self] on in
                self?.setEmailNotifications(on)
            },
            makeValueRow(icon: "moon.fill", title: "Qaranlıq rejim", valueLabel: appearanceValueLabel) { [weak self] in
                self?.chooseAppearance()
            }
        ])

        let accountCard = makeCard(rows: [
            makeChevronRow(icon: "person.fill", title: "Hesab məlumatları") { [weak self] in
                self?.pushAccountInfo()
            },
            makeChevronRow(icon: "lock.fill", title: "Parolu dəyiş") { [weak self] in
                self?.changePassword()
            }
        ])

        contentView.addSubview(generalCard)
        contentView.addSubview(accountCard)

        generalCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        accountCard.snp.makeConstraints { make in
            make.top.equalTo(generalCard.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
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
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setPush(_ on: Bool) {
        guard on else {
            UserDefaults.standard.set(false, forKey: Keys.push)
            saveSetting("push", false)
            return
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                UserDefaults.standard.set(granted, forKey: Keys.push)
                self.saveSetting("push", granted)
                if !granted {
                    self.presentAuthMessage("Bildirişlərə icazə verilməyib. iPhone Parametrlər → ElmiYol → Bildirişlər bölməsindən aktiv edin.")
                    self.reloadSwitches()
                }
            }
        }
    }

    private func setEmailNotifications(_ on: Bool) {
        UserDefaults.standard.set(on, forKey: Keys.email)
        saveSetting("emailNotifications", on)
    }

    private func saveSetting(_ key: String, _ value: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid)
            .setData(["settings": [key: value]], merge: true)
    }

    private func reloadSwitches() {
        viewDidLoad()
    }

    private func chooseAppearance() {
        let sheet = UIAlertController(title: "Qaranlıq rejim", message: nil, preferredStyle: .actionSheet)
        for mode in AppAppearance.allCases {
            let action = UIAlertAction(title: mode.title, style: .default) { [weak self] _ in
                AppearanceManager.shared.mode = mode
                self?.appearanceValueLabel.text = mode.title
            }
            if mode == AppearanceManager.shared.mode { action.setValue(true, forKey: "checked") }
            sheet.addAction(action)
        }
        sheet.addAction(UIAlertAction(title: "Bağla", style: .cancel))
        present(sheet, animated: true)
    }

    private func changePassword() {
        guard let user = Auth.auth().currentUser, let email = user.email else { return }

        let usesPassword = user.providerData.contains { $0.providerID == "password" }
        guard usesPassword else {
            presentAuthMessage("Siz Google ilə daxil olmusunuz. Parolu Google hesabınızdan dəyişə bilərsiniz.")
            return
        }

        let alert = UIAlertController(title: "Parolu dəyiş", message: "Təhlükəsizlik üçün cari parolu daxil edin.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Cari parol"; $0.isSecureTextEntry = true }
        alert.addTextField { $0.placeholder = "Yeni parol (min. 6 simvol)"; $0.isSecureTextEntry = true }
        alert.addTextField { $0.placeholder = "Yeni parolu təkrarlayın"; $0.isSecureTextEntry = true }
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Dəyiş", style: .default) { [weak self, weak alert] _ in
            let current = alert?.textFields?[0].text ?? ""
            let new = alert?.textFields?[1].text ?? ""
            let repeated = alert?.textFields?[2].text ?? ""

            guard new.count >= 6 else { self?.presentAuthMessage("Yeni parol ən azı 6 simvol olmalıdır."); return }
            guard new == repeated else { self?.presentAuthMessage("Yeni parollar eyni deyil."); return }

            let credential = EmailAuthProvider.credential(withEmail: email, password: current)
            user.reauthenticate(with: credential) { _, error in
                if let error { DispatchQueue.main.async { self?.presentAuthError(error) }; return }
                user.updatePassword(to: new) { error in
                    DispatchQueue.main.async {
                        if let error { self?.presentAuthError(error) }
                        else { self?.presentAuthMessage("Parol uğurla dəyişdirildi.", title: "Hazırdır") }
                    }
                }
            }
        })
        present(alert, animated: true)
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    private func makeCard(rows: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = AppColors.surface
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        return card
    }

    private func baseRow(icon: String, title: String) -> (UIView, UILabel) {
        let row = UIView()
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = AppColors.primary
        iconView.contentMode = .scaleAspectFit

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = AppColors.textPrimary

        row.addSubview(iconView)
        row.addSubview(label)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        label.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview().inset(14)
        }

        let separator = UIView()
        separator.backgroundColor = AppColors.separator
        row.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.equalTo(label)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return (row, label)
    }

    private func makeSwitchRow(icon: String, title: String, isOn: Bool, onChange: @escaping (Bool) -> Void) -> UIView {
        let (row, _) = baseRow(icon: icon, title: title)
        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = AppColors.primary
        toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)
        row.addSubview(toggle)
        toggle.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        return row
    }

    private func makeChevronRow(icon: String, title: String, onTap: @escaping () -> Void) -> UIView {
        let (row, _) = baseRow(icon: icon, title: title)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted
        row.addSubview(chevron)
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        addTap(row, onTap)
        return row
    }

    private func makeValueRow(icon: String, title: String, valueLabel: UILabel, onTap: @escaping () -> Void) -> UIView {
        let (row, _) = baseRow(icon: icon, title: title)
        valueLabel.font = .systemFont(ofSize: 13)
        valueLabel.textColor = AppColors.textSecondary
        valueLabel.text = AppearanceManager.shared.mode.title
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted
        row.addSubview(chevron)
        row.addSubview(valueLabel)
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        valueLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chevron.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
        addTap(row, onTap)
        return row
    }

    private var tapActions: [ObjectIdentifier: () -> Void] = [:]

    private func addTap(_ view: UIView, _ action: @escaping () -> Void) {
        view.isUserInteractionEnabled = true
        tapActions[ObjectIdentifier(view)] = action
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rowTapped(_:))))
    }

    @objc private func rowTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        tapActions[ObjectIdentifier(view)]?()
    }
    
}

