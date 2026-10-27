//
//  RegisterDropdownField.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class RegisterDropdownField: UIView {

    var onTap: (() -> Void)?
    private(set) var selectedValue: String?

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.down")
        iv.tintColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let placeholderText: String
    private let fieldTitle: String
    
    private let selectedTextColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
    private let placeholderTextColor = UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1)

    init(iconSystemName: String, title: String, placeholder: String) {
        self.placeholderText = placeholder
        self.fieldTitle = title
        super.init(frame: .zero)

        iconImageView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title
        valueLabel.text = placeholder

        setupHierarchy()
        setupConstraints()

        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(valueLabel)
        containerView.addSubview(chevronImageView)
        addSubview(errorLabel)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }

        iconContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        chevronImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(chevronImageView.snp.leading).offset(-8)
        }
        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview()
        }
    }

    @objc private func didTap() {
        onTap?()
    }
    func showRequiredError() {
        errorLabel.isHidden = false
           errorLabel.text = "\(fieldTitle) boş ola bilməz"
           containerView.layer.borderWidth = 1.5
           containerView.layer.borderColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1).cgColor
    }

    func clearError() {
        errorLabel.isHidden = true
        containerView.layer.borderWidth = 0
    }
    
    func showOptions(_ options: [String], from viewController: UIViewController) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in options {
            alert.addAction(UIAlertAction(title: option, style: .default, handler: { [weak self] _ in
                self?.setValue(option)
            }))
        }
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        viewController.present(alert, animated: true)
    }

    func setValue(_ value: String) {
        selectedValue = value
        valueLabel.text = value
        valueLabel.textColor = selectedTextColor
        clearError()
    }
    var isValidValue: Bool {
        selectedValue != nil && !(selectedValue?.isEmpty ?? true)
    }
}
