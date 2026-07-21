//
//  BaseTextField.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

protocol BaseTextFieldDelegate: AnyObject {
    func textFieldDidChangeValidation(_ textField: BaseTextField, isValid: Bool)
}

final class BaseTextField: UIView {

    weak var validationDelegate: BaseTextFieldDelegate?

    private var validator: FieldValidator?
    private(set) var isValidValue: Bool = true
    private let isPhoneField: Bool
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()

    let textField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16, weight: .medium)
        field.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return field
    }()

    private let toggleSecureButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.isHidden = true
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1)
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()

    private let isSecureField: Bool
    private var confirmPasswordProvider: (() -> String)?

    init(iconSystemName: String, title: String, placeholder: String, isSecure: Bool = false, keyboardType: UIKeyboardType = .default, isPhoneField: Bool = false) {
        self.isSecureField = isSecure
        self.isPhoneField = isPhoneField
        super.init(frame: .zero)

        iconImageView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(red: 0.65, green: 0.68, blue: 0.75, alpha: 1)]
        )
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = isPhoneField ? .numberPad : keyboardType

        setupHierarchy()
        setupConstraints()
        setupActions()

        toggleSecureButton.isHidden = !isSecure
        
        if isPhoneField {
                   textField.text = "+994 "
                   textField.delegate = self
               }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(toggleSecureButton)
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

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.trailing.equalTo(toggleSecureButton.snp.leading).offset(-8)
        }

        textField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(toggleSecureButton.snp.leading).offset(-8)
        }

        toggleSecureButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        errorLabel.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview()
        }
    }

    private func setupActions() {
        toggleSecureButton.addAction(UIAction { [weak self] _ in
            self?.toggleSecureEntry()
        }, for: .touchUpInside)

        textField.addAction(UIAction { [weak self] _ in
            self?.runLiveValidation()
        }, for: .editingChanged)
    }

    func setValidator(_ type: ValidatorType) {
        self.validator = FieldValidator(type: type)
    }

    private func toggleSecureEntry() {
        textField.isSecureTextEntry.toggle()
        let imageName = textField.isSecureTextEntry ? "eye" : "eye.slash"
        toggleSecureButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func runLiveValidation() {
       
        if isValidValue == false {
            _ = validate(showError: true)
        }
    }

    @discardableResult
    func validate(showError: Bool = true) -> Bool {
        guard let validator = validator else {
            isValidValue = true
            return true
        }
        let result = validator.validate(textField.text ?? "")
        isValidValue = result.isValid

        if showError {
            setErrorState(!result.isValid, message: result.errorMessage)
        }

        validationDelegate?.textFieldDidChangeValidation(self, isValid: result.isValid)
        return result.isValid
    }

    private func setErrorState(_ hasError: Bool, message: String?) {
        errorLabel.isHidden = !hasError
        errorLabel.text = message
        containerView.layer.borderWidth = hasError ? 1.5 : 0
        containerView.layer.borderColor = UIColor(red: 0.9, green: 0.25, blue: 0.25, alpha: 1).cgColor
    }

    var value: String {
        textField.text ?? ""
    }
    
    var values: String {
            if isPhoneField {
                return textField.text ?? "+994 "
            }
            return textField.text ?? ""
        }
}

extension BaseTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard isPhoneField else { return true }

        let prefix = "+994 "

        if range.location < prefix.count {
            return false
        }

        guard let currentText = textField.text as NSString? else { return false }
        let proposedText = currentText.replacingCharacters(in: range, with: string)

        let digitsAfterPrefix = proposedText
            .replacingOccurrences(of: prefix, with: "")
            .filter { $0.isNumber }

        if string.isEmpty {
            return true
        }

        if !string.allSatisfy({ $0.isNumber }) {
            return false
        }

        guard digitsAfterPrefix.count <= 9 else {
            return false
        }

        return true
    }
}
