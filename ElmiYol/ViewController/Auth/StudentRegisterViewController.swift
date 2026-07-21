//
//  StudentRegisterViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class StudentRegisterViewController: UIViewController {

    private var model = StudentRegisterModel()

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

    private let studentImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "role_student_illustration")
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
        let text = "Magistr tələbəsi\nQeydiyyatı"
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
        label.text = "Hesab yaradaraq ElmiYol-un bütün imkanlarından faydalanın."
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
    private let universityField = RegisterDropdownField(iconSystemName: "building.columns", title: "Universitet", placeholder: "Universitetinizi seçin")
    private let facultyField = RegisterDropdownField(iconSystemName: "person.text.rectangle", title: "Fakültə", placeholder: "Fakültənizi seçin")
    private let specialityField = RegisterDropdownField(iconSystemName: "graduationcap", title: "İxtisas", placeholder: "İxtisasınızı seçin")
    private let groupNumberField = BaseTextField(iconSystemName: "number", title: "Qrup nömrəsi", placeholder: "Məs: 704a2")
    private let studyYearsField = RegisterDropdownField(iconSystemName: "calendar", title: "Təhsil illəri", placeholder: "Təhsil illərinizi seçin")
    private let passwordField = BaseTextField(iconSystemName: "lock", title: "Şifrə", placeholder: "Şifrə yaradın", isSecure: true)
    private let confirmPasswordField = BaseTextField(iconSystemName: "lock", title: "Şifrəni təkrar daxil edin", placeholder: "Şifrəni təkrar edin", isSecure: true)

    private let termsView = CheckboxTermsView(confirmationText: "Məlumatların düzgün olduğunu təsdiqləyirəm və")

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

    private let universityOptions = ["Bakı Dövlət Universiteti", "ADA Universiteti", "Xəzər Universiteti", "Azərbaycan Texniki Universiteti", "UNEC"]
    private let facultyOptions = ["Kompüter Elmləri", "İqtisadiyyat", "Filologiya", "Hüquq", "Fizika"]
    private let specialityOptions = ["Proqram Mühəndisliyi", "Maliyyə", "Marketinq", "Beynəlxalq Münasibətlər"]
    private let studyYearsOptions: [String] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0...3).map { offset in
            let start = currentYear + offset
            let end = start + 2
            return "\(start)-\(end)"
        }
    }()

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
        contentView.addSubview(studentImageView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formContainerView)

        let fieldsStack = UIStackView(arrangedSubviews: [
            firstNameField, lastNameField, emailField, phoneField,
            universityField, facultyField, specialityField,
            groupNumberField, studyYearsField,
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

        studentImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(160)
            make.height.equalTo(200)
        }

        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalTo(studentImageView.snp.trailing).offset(16)
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
            make.top.equalTo(studentImageView.snp.bottom).offset(24)
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
        groupNumberField.setValidator(.required(fieldName: "Qrup nömrəsi"))
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

        universityField.onTap = { [weak self] in
            guard let self = self else { return }
            self.universityField.showOptions(self.universityOptions, from: self)
        }

        facultyField.onTap = { [weak self] in
            guard let self = self else { return }
            self.facultyField.showOptions(self.facultyOptions, from: self)
        }

        specialityField.onTap = { [weak self] in
            guard let self = self else { return }
            self.specialityField.showOptions(self.specialityOptions, from: self)
        }

        studyYearsField.onTap = { [weak self] in
            guard let self = self else { return }
            self.studyYearsField.showOptions(self.studyYearsOptions, from: self)
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
        let isGroupNumberValid = groupNumberField.validate()
        let isPasswordValid = passwordField.validate()
        let isConfirmPasswordValid = confirmPasswordField.validate()

        let isUniversityValid = universityField.isValidValue
        let isFacultyValid = facultyField.isValidValue
        let isSpecialityValid = specialityField.isValidValue
        let isStudyYearsValid = studyYearsField.isValidValue

        if !isUniversityValid { universityField.showRequiredError() }
        if !isFacultyValid { facultyField.showRequiredError() }
        if !isSpecialityValid { specialityField.showRequiredError() }
        if !isStudyYearsValid { studyYearsField.showRequiredError() }

        guard isFirstNameValid, isLastNameValid, isEmailValid, isPhoneValid, isGroupNumberValid,
              isPasswordValid, isConfirmPasswordValid,
              isUniversityValid, isFacultyValid, isSpecialityValid, isStudyYearsValid else {
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
        model.university = universityField.selectedValue ?? ""
        model.faculty = facultyField.selectedValue ?? ""
        model.speciality = specialityField.selectedValue ?? ""
        model.groupNumber = groupNumberField.value
        model.studyYears = studyYearsField.selectedValue ?? ""
        model.password = passwordField.value
        model.confirmPassword = confirmPasswordField.value
        model.acceptedTerms = termsView.isChecked

        guard model.isComplete else { return }
        
        UserSession.shared.studentData = model
        UserSession.shared.currentRole = .student
        
        guard !didNavigate else { return }
        didNavigate = true
        AppRouter.shared.push(.studentMainTabBar)
    }

    private func showTermsAlert() {
        let alert = UIAlertController(title: "Diqqət", message: "Davam etmək üçün istifadə şərtləri ilə razılaşmalısınız.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }
}
