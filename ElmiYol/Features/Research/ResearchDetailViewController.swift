//
//  ResearchDetailViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

final class ResearchDetailViewController: UIViewController {

    private let item: ResearchItem

    init(item: ResearchItem) {
        self.item = item
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

    private let startDateRow = DetailInfoRow(iconSystemName: "calendar", title: "Başlama tarixi")
    private let endDateRow = DetailInfoRow(iconSystemName: "calendar.badge.clock", title: "Bitmə tarixi")
    private let progressCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "İrəliləyiş"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = AppColors.textPrimary
        return label
    }()
    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = AppColors.primary
        return label
    }()
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 5
        return view
    }()
    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = 5
        return view
    }()

    private let filesCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let filesTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fayllar"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let emptyFilesLabel: UILabel = {
        let label = UILabel()
        label.text = "Hələ ki fayl əlavə edilməyib."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let messageButton = BaseButton(title: "Rəhbərə mesaj yaz", style: .secondary, showsArrow: false)

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        progressFillView.frame = CGRect(
            x: 0, y: 0,
            width: progressTrackView.bounds.width * CGFloat(item.progress),
            height: progressTrackView.bounds.height
        )
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        contentView.addSubview(backButton)
        statusBadgeView.addSubview(statusLabel)
        contentView.addSubview(statusBadgeView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(personLabel)

        contentView.addSubview(infoCardView)
        infoCardView.addSubview(startDateRow)
        infoCardView.addSubview(endDateRow)
        infoCardView.addSubview(progressCaptionLabel)
        infoCardView.addSubview(progressPercentLabel)
        infoCardView.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)

        contentView.addSubview(filesCardView)
        filesCardView.addSubview(filesTitleLabel)
        filesCardView.addSubview(emptyFilesLabel)

        contentView.addSubview(messageButton)
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

        startDateRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        endDateRow.snp.makeConstraints { make in
            make.top.equalTo(startDateRow.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        progressCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(endDateRow.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressCaptionLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        progressTrackView.snp.makeConstraints { make in
            make.top.equalTo(progressCaptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(10)
            make.bottom.equalToSuperview().offset(-20)
        }

        filesCardView.snp.makeConstraints { make in
            make.top.equalTo(infoCardView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        filesTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        emptyFilesLabel.snp.makeConstraints { make in
            make.top.equalTo(filesTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        messageButton.snp.makeConstraints { make in
            make.top.equalTo(filesCardView.snp.bottom).offset(24)
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

        messageButton.addAction(UIAction { [weak self] _ in
            self?.handleMessageTap()
        }, for: .touchUpInside)
    }

    private func handleMessageTap() {
        tabBarController?.selectedIndex = NotificationsOrigin.messages.rawValue
        navigationController?.popToRootViewController(animated: false)
    }

    private func configure() {
        statusLabel.text = item.statusText
        statusLabel.textColor = item.statusTint
        statusBadgeView.backgroundColor = item.statusBackground
        statusBadgeView.layer.cornerRadius = 13

        titleLabel.text = item.titleText
        personLabel.text = item.personText

        startDateRow.setValue(item.startDateText)
        endDateRow.setValue(item.endDateText)

        progressPercentLabel.text = "\(Int(item.progress * 100))%"
    }
}

final class DetailInfoRow: UIView {

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = AppColors.textSecondary
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = AppColors.textSecondary
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    init(iconSystemName: String, title: String) {
        super.init(frame: .zero)
        iconImageView.image = UIImage(systemName: iconSystemName)
        titleLabel.text = title

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(valueLabel)

        iconImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
        }

        valueLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        snp.makeConstraints { $0.height.equalTo(20) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(_ value: String) {
        valueLabel.text = value
    }
}
