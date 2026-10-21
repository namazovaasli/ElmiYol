//
//  PrivacySecurityViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

final class PrivacySecurityViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    private let contentView = UIView()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.primary
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 24
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gizlilik və təhlükəsizlik"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Məlumatlarınızın qorunması və hesab təhlükəsizliyi."
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        let securityCard = makeOptionCard(
            title: "Təhlükəsizlik",
            rows: [
                ("faceid", "Biometrik giriş", true),
                ("key.fill", "İki mərhələli doğrulama", false),
                ("lock.rotation", "Aktiv sessiyaları idarə et", false)
            ]
        )
        contentView.addSubview(securityCard)

        let privacyCard = makeOptionCard(
            title: "Gizlilik",
            rows: [
                ("eye.slash.fill", "Profilimi yalnız rəhbərə göstər", true),
                ("doc.text.fill", "Məlumatların saxlanması siyasəti", false),
                ("hand.raised.fill", "Hesabı dondur", false)
            ]
        )
        contentView.addSubview(privacyCard)

        securityCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        privacyCard.snp.makeConstraints { make in
            make.top.equalTo(securityCard.snp.bottom).offset(16)
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

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)
    }

    private func makeOptionCard(title: String, rows: [(String, String, Bool)]) -> UIView {
        let container = UIView()
        let header = UILabel()
        header.text = title
        header.font = .systemFont(ofSize: 17, weight: .bold)
        header.textColor = AppColors.textPrimary
        container.addSubview(header)

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12
        container.addSubview(card)

        let stack = UIStackView()
        stack.axis = .vertical
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }

        for row in rows {
            stack.addArrangedSubview(makeRow(icon: row.0, title: row.1, hasSwitch: row.2))
        }

        header.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container
    }

    private func makeRow(icon: String, title: String, hasSwitch: Bool) -> UIView {
        let row = UIView()
        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = AppColors.primary
        iconView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.numberOfLines = 2

        row.addSubview(iconView)
        row.addSubview(titleLabel)
        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(12)
            make.top.bottom.equalToSuperview().inset(14)
            make.trailing.lessThanOrEqualToSuperview().offset(-70)
        }

        if hasSwitch {
            let toggle = UISwitch()
            toggle.isOn = title.contains("Biometrik") || title.contains("rəhbərə")
            toggle.onTintColor = AppColors.primary
            row.addSubview(toggle)
            toggle.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
            }
        } else {
            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = AppColors.textMuted
            row.addSubview(chevron)
            chevron.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(12)
            }
        }

        let separator = UIView()
        separator.backgroundColor = AppColors.separator
        row.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        return row
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }
}
