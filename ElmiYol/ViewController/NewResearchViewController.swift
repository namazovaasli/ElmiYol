//
//  NewResearchViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

final class NewResearchViewController: UIViewController {

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
        button.tintColor = AppColors.primary
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Yeni tədqiqat"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tədqiqatınız haqqında məlumatları daxil edin."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppColors.textSecondary
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

    private let titleField = BaseTextField(iconSystemName: "doc.text", title: "Tədqiqatın adı", placeholder: "Məs: Süni intellektin təhsildə tətbiqi")
    private let supervisorField = RegisterDropdownField(iconSystemName: "person", title: "Elmi rəhbər", placeholder: "Rəhbərinizi seçin")
    private let categoryField = RegisterDropdownField(iconSystemName: "folder", title: "Kateqoriya", placeholder: "Kateqoriya seçin")
    private let startDateField = BaseTextField(iconSystemName: "calendar", title: "Başlama tarixi", placeholder: "GG.AA.YYYY")
    private let endDateField = BaseTextField(iconSystemName: "calendar", title: "Bitmə tarixi", placeholder: "GG.AA.YYYY")
    private let descriptionField = BaseTextField(iconSystemName: "text.alignleft", title: "Qısa təsvir", placeholder: "Tədqiqatın qısa təsviri")

    private let createButton = BaseButton(title: "Tədqiqatı əlavə et", style: .primary, showsArrow: true)

    private let supervisorOptions = ["Prof. Dr. İlqar Məmmədov", "Prof. Dr. Aygün Əliyeva"]
    private let categoryOptions = ["Süni intellekt", "Kibertəhlükəsizlik", "Data analitikası", "Mobil tətbiqlər", "Digər"]

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
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(formContainerView)

        let fieldsStack = UIStackView(arrangedSubviews: [
            titleField, supervisorField, categoryField, startDateField, endDateField, descriptionField
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

        contentView.addSubview(createButton)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        formContainerView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(formContainerView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupValidators() {
        titleField.setValidator(.required(fieldName: "Tədqiqatın adı"))
        startDateField.setValidator(.required(fieldName: "Başlama tarixi"))
        endDateField.setValidator(.required(fieldName: "Bitmə tarixi"))
        descriptionField.setValidator(.required(fieldName: "Qısa təsvir"))
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        createButton.addAction(UIAction { [weak self] _ in
            self?.handleCreateTap()
        }, for: .touchUpInside)

        supervisorField.onTap = { [weak self] in
            guard let self else { return }
            self.supervisorField.showOptions(self.supervisorOptions, from: self)
        }

        categoryField.onTap = { [weak self] in
            guard let self else { return }
            self.categoryField.showOptions(self.categoryOptions, from: self)
        }
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    private func handleCreateTap() {
        let isTitleValid = titleField.validate()
        let isStartValid = startDateField.validate()
        let isEndValid = endDateField.validate()
        let isDescriptionValid = descriptionField.validate()

        let isSupervisorValid = supervisorField.isValidValue
        let isCategoryValid = categoryField.isValidValue

        if !isSupervisorValid { supervisorField.showRequiredError() }
        if !isCategoryValid { categoryField.showRequiredError() }

        guard isTitleValid, isStartValid, isEndValid, isDescriptionValid,
              isSupervisorValid, isCategoryValid else { return }

        guard !didNavigate else { return }
        didNavigate = true

        let alert = UIAlertController(
            title: "Tədqiqat əlavə edildi",
            message: "Yeni tədqiqat sorğunuz qeydə alındı.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.navigationController?.popViewControllerWithFade()
        })
        present(alert, animated: true)
    }
}
