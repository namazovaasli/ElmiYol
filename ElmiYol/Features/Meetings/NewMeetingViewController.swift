//
//  NewMeetingViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

final class NewMeetingViewController: UIViewController {

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
        label.text = "Yeni görüş"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Görüş üçün məlumatları daxil edin."
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

    private let titleField = BaseTextField(iconSystemName: "textformat", title: "Görüşün adı", placeholder: "Məs: Rəhbərlik görüşü")
    private let personField = RegisterDropdownField(iconSystemName: "person", title: "İştirakçı", placeholder: "İştirakçını seçin")
    private let dateField = BaseTextField(iconSystemName: "calendar", title: "Tarix", placeholder: "GG.AA.YYYY")
    private let startTimeField = BaseTextField(iconSystemName: "clock", title: "Başlama vaxtı", placeholder: "14:00")
    private let endTimeField = BaseTextField(iconSystemName: "clock", title: "Bitmə vaxtı", placeholder: "15:00")
    private let modeField = RegisterDropdownField(iconSystemName: "video", title: "Format", placeholder: "Online/Offline seçin")
    private let locationField = BaseTextField(iconSystemName: "mappin.and.ellipse", title: "Yer / Link", placeholder: "Zoom linki və ya otaq nömrəsi")
    private let noteField = BaseTextField(iconSystemName: "note.text", title: "Qeyd (istəyə bağlı)", placeholder: "Əlavə qeyd yazın")

    private let createButton = BaseButton(title: "Görüşü yarat", style: .primary, showsArrow: true)

    private let personOptions = ["Prof. Dr. İlqar Məmmədov", "Prof. Dr. Aygün Əliyeva", "Əsli Namazova", "Rəşad Hüseynli", "Nigar Əliyeva"]
    private let modeOptions = ["Online (Zoom)", "Online (Google Meet)", "Online (Microsoft Teams)", "Offline (Universitet)"]

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
            titleField, personField, dateField, startTimeField, endTimeField, modeField, locationField, noteField
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
        titleField.setValidator(.required(fieldName: "Görüşün adı"))
        dateField.setValidator(.required(fieldName: "Tarix"))
        startTimeField.setValidator(.required(fieldName: "Başlama vaxtı"))
        endTimeField.setValidator(.required(fieldName: "Bitmə vaxtı"))
        locationField.setValidator(.required(fieldName: "Yer / Link"))
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        createButton.addAction(UIAction { [weak self] _ in
            self?.handleCreateTap()
        }, for: .touchUpInside)

        personField.onTap = { [weak self] in
            guard let self else { return }
            self.personField.showOptions(self.personOptions, from: self)
        }

        modeField.onTap = { [weak self] in
            guard let self else { return }
            self.modeField.showOptions(self.modeOptions, from: self)
        }
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    private func handleCreateTap() {
        let isTitleValid = titleField.validate()
        let isDateValid = dateField.validate()
        let isStartValid = startTimeField.validate()
        let isEndValid = endTimeField.validate()
        let isLocationValid = locationField.validate()

        let isPersonValid = personField.isValidValue
        let isModeValid = modeField.isValidValue

        if !isPersonValid { personField.showRequiredError() }
        if !isModeValid { modeField.showRequiredError() }

        guard isTitleValid, isDateValid, isStartValid, isEndValid, isLocationValid,
              isPersonValid, isModeValid else { return }

        guard !didNavigate else { return }
        didNavigate = true

        let alert = UIAlertController(
            title: "Görüş yaradıldı",
            message: "Yeni görüş uğurla planlaşdırıldı.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.navigationController?.popViewControllerWithFade()
        })
        present(alert, animated: true)
    }
}
