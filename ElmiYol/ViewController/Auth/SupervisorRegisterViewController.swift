//
//  SupervisorRegisterViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class SupervisorRegisterViewController: UIViewController {

    private var model = SupervisorRegisterModel()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()
    private let contentView = UIView()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let supervisorImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "role_supervisor_illustration")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "elmiyol_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let text = "Elmi rəhbər\nQeydiyyatı"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )
        if let range = text.range(of: "Qeydiyyatı") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
        }
        label.attributedText = attributed
        label.numberOfLines = 2
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elmi rəhbər kimi platformaya qoşulun, tələbələrə dəstək olun, işləri idarə edin."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
        return label
    }()

    private let formContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()

    private let firstNameField = BaseTextField(iconSystemName: "person", title: "Ad", placeholder: "Adınızı daxil edin")
    private let lastNameField = BaseTextField(iconSystemName: "person", title: "Soyad", placeholder: "Soyadınızı daxil edin")
    private let emailField = BaseTextField(iconSystemName: "envelope", title: "E-poçt ünvanı", placeholder: "example@mail.com", keyboardType: .emailAddress)
    private let phoneField = BaseTextField(iconSystemName: "phone", title: "Telefon nömrəsi", placeholder: "50 123 45 67", isPhoneField: true)
    private let workplaceField = RegisterDropdownField(iconSystemName: "building.columns", title: "İş yeri / Universitet", placeholder: "İş yerinizi daxil edin")
    private let positionField = RegisterDropdownField(iconSystemName: "person.text.rectangle", title: "Vəzifə", placeholder: "Vəzifənizi seçin")
    private let academicDegreeField = RegisterDropdownField(iconSystemName: "graduationcap", title: "Elmi dərəcə", placeholder: "Elmi dərəcənizi seçin")
    private let specialityFieldSupervisor = RegisterDropdownField(iconSystemName: "book", title: "İxtisas sahəsi", placeholder: "İxtisas sahənizi seçin")
    private let passwordField = BaseTextField(iconSystemName: "lock", title: "Şifrə", placeholder: "Şifrə yaradın", isSecure: true)
    private let confirmPasswordField = BaseTextField(iconSystemName: "lock", title: "Şifrəni təkrar daxil edin", placeholder: "Şifrəni təkrar edin", isSecure: true)

    private let termsView = CheckboxTermsView(confirmationText: "Məlumatların düzgün olduğunu təsdiq edirəm və")

    private let registerButton = BaseButton(title: "Qeydiyyatdan keç", style: .primary, showsArrow: true)

    private let loginPromptLabel: UILabel = {
        let label = UILabel()
        let text = "Artıq hesabınız var? Daxil ol"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
            ]
        )
        if let range = text.range(of: "Daxil ol") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: nsRange)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
        }
        label.attributedText = attributed
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    
    private let workplaceOptions = ["Bakı Dövlət Universiteti", "ADA Universiteti", "Xəzər Universiteti", "Azərbaycan Texniki Universiteti", "UNEC"]
    private let positionOptions = ["Professor", "Dosent", "Baş müəllim", "Assistent"]
    private let academicDegreeOptions = ["Elmlər doktoru", "Fəlsəfə doktoru (PhD)", "Dosent", "Professor"]
    private let specialityOptionsSupervisor = ["Kompüter Elmləri", "İqtisadiyyat", "Filologiya", "Hüquq", "Fizika"]

    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupView()
        setupConstraints()
        setupValidators()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(supervisorImageView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formContainerView)

        let fieldsStack = UIStackView(arrangedSubviews: [
            firstNameField, lastNameField, emailField, phoneField,
            workplaceField, positionField, academicDegreeField, specialityFieldSupervisor,
            passwordField, confirmPasswordField
        ])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 16
        formContainerView.addSubview(fieldsStack)
        fieldsStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }

        contentView.addSubview(termsView)
        contentView.addSubview(registerButton)
        contentView.addSubview(loginPromptLabel)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
                        make.leading.equalToSuperview().offset(20)
                        make.width.height.equalTo(48)
        }

        supervisorImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(160)
            make.height.equalTo(200)
        }

        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalTo(supervisorImageView.snp.trailing).offset(16)
            make.width.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(12)
            make.leading.equalTo(logoImageView)
            make.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(logoImageView)
            make.trailing.equalToSuperview().offset(-20)
        }

        formContainerView.snp.makeConstraints { make in
            make.top.equalTo(supervisorImageView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        termsView.snp.makeConstraints { make in
            make.top.equalTo(formContainerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        registerButton.snp.makeConstraints { make in
            make.top.equalTo(termsView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(58)
        }

        loginPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(registerButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupValidators() {
        firstNameField.setValidator(.name)
        lastNameField.setValidator(.surname)
        emailField.setValidator(.email)
        phoneField.setValidator(.phone)
        passwordField.setValidator(.password)
        confirmPasswordField.setValidator(.confirmPassword(originalPassword: { [weak self] in
            self?.passwordField.value ?? ""
        }))
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        registerButton.addAction(UIAction { [weak self] _ in
            self?.handleRegisterTap()
        }, for: .touchUpInside)
        workplaceField.onTap = { [weak self] in
            guard let self = self else { return }
            self.workplaceField.showOptions(self.workplaceOptions, from: self)
        }

        positionField.onTap = { [weak self] in
            guard let self = self else { return }
            self.positionField.showOptions(self.positionOptions, from: self)
        }

        academicDegreeField.onTap = { [weak self] in
            guard let self = self else { return }
            self.academicDegreeField.showOptions(self.academicDegreeOptions, from: self)
        }

        specialityFieldSupervisor.onTap = { [weak self] in
            guard let self = self else { return }
            self.specialityFieldSupervisor.showOptions(self.specialityOptionsSupervisor, from: self)
        }

        loginPromptLabel.isUserInteractionEnabled = true
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(didTapLogin))
        loginPromptLabel.addGestureRecognizer(loginTap)
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    @objc private func didTapLogin() {
        guard !didNavigate else { return }
        didNavigate = true
        AppRouter.shared.push(.login)
    }

    private func handleRegisterTap() {
        let isFirstNameValid = firstNameField.validate()
        let isLastNameValid = lastNameField.validate()
        let isEmailValid = emailField.validate()
        let isPhoneValid = phoneField.validate()
        let isWorkplaceValid = workplaceField.isValidValue
        
        let isPasswordValid = passwordField.validate()
        let isConfirmPasswordValid = confirmPasswordField.validate()

        let isPositionValid = positionField.isValidValue
        let isAcademicDegreeValid = academicDegreeField.isValidValue
        let isSpecialityValid = specialityFieldSupervisor.isValidValue

        if !isWorkplaceValid { workplaceField.showRequiredError() }

        if !isPositionValid { positionField.showRequiredError() }
        if !isAcademicDegreeValid { academicDegreeField.showRequiredError() }
        if !isSpecialityValid { specialityFieldSupervisor.showRequiredError() }

        guard isFirstNameValid, isLastNameValid, isEmailValid, isPhoneValid, isWorkplaceValid,
              isPasswordValid, isConfirmPasswordValid,
              isPositionValid, isAcademicDegreeValid, isSpecialityValid else {
            return
        }

        guard termsView.isChecked else {
            showTermsAlert()
            return
        }

        model.firstName = firstNameField.value
        model.lastName = lastNameField.value
        model.email = emailField.value
        model.phone = phoneField.value
        model.workplace = workplaceField.selectedValue ?? ""
        model.position = positionField.selectedValue ?? ""
        model.academicDegree = academicDegreeField.selectedValue ?? ""
        model.specialityField = specialityFieldSupervisor.selectedValue ?? ""
        model.password = passwordField.value
        model.confirmPassword = confirmPasswordField.value
        model.acceptedTerms = termsView.isChecked

        guard model.isComplete else { return }
        
        UserSession.shared.supervisorData = model
        UserSession.shared.currentRole = .supervisor
        
        guard !didNavigate else { return }
        didNavigate = true
        AppRouter.shared.push(.supervisorMainTabBar)
    }

    private func showTermsAlert() {
        let alert = UIAlertController(title: "Diqqət", message: "Davam etmək üçün istifadə şərtləri ilə razılaşmalısınız.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }
}
