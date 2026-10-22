//
//  MeetingDetailViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

struct MeetingDetailData {
    let titleText: String
    let personText: String
    let dateText: String
    let timeText: String
    let modeText: String
    let statusText: String
    let statusTint: UIColor
    let statusBackground: UIColor
}

final class MeetingDetailViewController: UIViewController {

    private let data: MeetingDetailData

    init(data: MeetingDetailData) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.textPrimary
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let statusBadgeView = UIView()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 0
        return label
    }()

    private let personLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let infoCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let dateRow = DetailInfoRow(iconSystemName: "calendar", title: "Tarix")
    private let timeRow = DetailInfoRow(iconSystemName: "clock", title: "Vaxt")
    private let modeRow = DetailInfoRow(iconSystemName: "video", title: "Format")

    private let joinButton = BaseButton(title: "Görüşə qoşul", style: .primary, showsArrow: false)
    private let cancelButton = BaseButton(title: "Görüşü ləğv et", style: .secondary, showsArrow: false)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        setupView()
        setupConstraints()
        setupActions()
        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        contentView.addSubview(optionsButton)
        statusBadgeView.addSubview(statusLabel)
        contentView.addSubview(statusBadgeView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(personLabel)

        contentView.addSubview(infoCardView)
        infoCardView.addSubview(dateRow)
        infoCardView.addSubview(timeRow)
        infoCardView.addSubview(modeRow)

        contentView.addSubview(joinButton)
        contentView.addSubview(cancelButton)
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

        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(backButton)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(48)
        }

        statusBadgeView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(26)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadgeView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        personLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        infoCardView.snp.makeConstraints { make in
            make.top.equalTo(personLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        dateRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        timeRow.snp.makeConstraints { make in
            make.top.equalTo(dateRow.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        modeRow.snp.makeConstraints { make in
            make.top.equalTo(timeRow.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        joinButton.snp.makeConstraints { make in
            make.top.equalTo(infoCardView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
        }

        cancelButton.snp.makeConstraints { make in
            make.top.equalTo(joinButton.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(54)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewControllerWithFade()
        }, for: .touchUpInside)

        optionsButton.addAction(UIAction { [weak self] _ in
            self?.handleOptionsTap()
        }, for: .touchUpInside)

        cancelButton.addAction(UIAction { [weak self] _ in
            self?.handleCancelTap()
        }, for: .touchUpInside)

        joinButton.addAction(UIAction { [weak self] _ in
            self?.handleJoinTap()
        }, for: .touchUpInside)
    }

    private func handleJoinTap() {
        let alert = UIAlertController(
            title: "Görüşə qoşul",
            message: "\(data.modeText) üzərindən görüşə qoşulmaq üçün link açılacaq.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Bağla", style: .cancel))
        alert.addAction(UIAlertAction(title: "Qoşul", style: .default))
        present(alert, animated: true)
    }

    private func handleOptionsTap() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Redaktə et", style: .default) { [weak self] _ in
            self?.presentEditPlaceholder()
        })
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.presentDeleteConfirmation()
        })
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        if let popover = alert.popoverPresentationController {
            popover.sourceView = optionsButton
            popover.sourceRect = optionsButton.bounds
        }
        present(alert, animated: true)
    }

    private func presentEditPlaceholder() {
        let alert = UIAlertController(
            title: "Redaktə",
            message: "Görüş məlumatlarını redaktə etmək tezliklə mövcud olacaq.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Bağla", style: .default))
        present(alert, animated: true)
    }

    private func presentDeleteConfirmation() {
        let alert = UIAlertController(
            title: "Görüşü sil",
            message: "Bu görüşü silmək istədiyinizə əminsiniz?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Xeyr", style: .cancel))
        alert.addAction(UIAlertAction(title: "Bəli, sil", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewControllerWithFade()
        })
        present(alert, animated: true)
    }

    private func handleCancelTap() {
        let alert = UIAlertController(
            title: "Görüşü ləğv et",
            message: "Bu görüşü ləğv etmək istədiyinizə əminsiniz?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Xeyr", style: .cancel))
        alert.addAction(UIAlertAction(title: "Bəli, ləğv et", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewControllerWithFade()
        })
        present(alert, animated: true)
    }

    private func configure() {
        statusLabel.text = data.statusText
        statusLabel.textColor = data.statusTint
        statusBadgeView.backgroundColor = data.statusBackground
        statusBadgeView.layer.cornerRadius = 13

        titleLabel.text = data.titleText
        personLabel.text = data.personText

        dateRow.setValue(data.dateText)
        timeRow.setValue(data.timeText)
        modeRow.setValue(data.modeText)
    }
}
