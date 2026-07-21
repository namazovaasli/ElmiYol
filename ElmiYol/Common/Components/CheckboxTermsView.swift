//
//  CheckboxTermsView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class CheckboxTermsView: UIView {

    var onToggle: ((Bool) -> Void)?

    private(set) var isChecked: Bool = false

    private let checkboxButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1).cgColor
        return button
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    init(confirmationText: String) {
        super.init(frame: .zero)
        setupHierarchy()
        setupConstraints()
        setupText(confirmationText)
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(checkboxButton)
        addSubview(textLabel)
    }

    private func setupConstraints() {
        checkboxButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.width.height.equalTo(24)
        }

        textLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalTo(checkboxButton.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    private func setupText(_ confirmationText: String) {
        let fullText = "\(confirmationText) İstifadə şərtləri və Gizlilik siyasəti ilə razıyam."
        let attributed = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                .foregroundColor: UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
            ]
        )
        if let range = fullText.range(of: "İstifadə şərtləri") {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: nsRange)
        }
        if let range = fullText.range(of: "Gizlilik siyasəti") {
            let nsRange = NSRange(range, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: nsRange)
        }
        textLabel.attributedText = attributed
    }

    private func setupActions() {
        checkboxButton.addAction(UIAction { [weak self] _ in
            self?.toggleCheckbox()
        }, for: .touchUpInside)
    }

    private func toggleCheckbox() {
        isChecked.toggle()
        updateCheckboxAppearance()
        onToggle?(isChecked)
    }

    private func updateCheckboxAppearance() {
        if isChecked {
            checkboxButton.backgroundColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
            checkboxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkboxButton.tintColor = .white
        } else {
            checkboxButton.backgroundColor = .clear
            checkboxButton.setImage(nil, for: .normal)
        }
    }
}
