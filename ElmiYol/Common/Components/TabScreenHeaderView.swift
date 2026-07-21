//
//  TabScreenHeaderView.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

protocol TabScreenHeaderViewDelegate: AnyObject {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView)
    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView)
}

final class TabScreenHeaderView: UIView {

    weak var delegate: TabScreenHeaderViewDelegate?

    var notificationBadgeCount: Int = 3 {
        didSet { updateBadge() }
    }

    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.textPrimary
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = AppColors.cardShadow
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "elmiyol_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let logoTitleLabel: UILabel = {
        let label = UILabel()
        let text = "ElmiYol"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: AppColors.textPrimary
            ]
        )
        if let range = text.range(of: "Yol") {
            attributed.addAttribute(.foregroundColor, value: AppColors.primary, range: NSRange(range, in: text))
        }
        label.attributedText = attributed
        return label
    }()

    private let logoStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = AppColors.textPrimary
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = AppColors.cardShadow
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let notificationBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.badgeRed
        view.layer.cornerRadius = 9
        return view
    }()

    private let notificationBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        logoStack.addArrangedSubview(logoImageView)
        logoStack.addArrangedSubview(logoTitleLabel)

        addSubview(menuButton)
        addSubview(logoStack)
        addSubview(notificationButton)
        notificationButton.addSubview(notificationBadgeView)
        notificationBadgeView.addSubview(notificationBadgeLabel)

        menuButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.height.equalTo(48)
        }

        logoStack.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        notificationButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.height.equalTo(48)
        }

        notificationBadgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-2)
            make.trailing.equalToSuperview().offset(2)
            make.width.height.equalTo(18)
        }

        notificationBadgeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        menuButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.tabScreenHeaderDidTapMenu(self)
        }, for: .touchUpInside)

        notificationButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.delegate?.tabScreenHeaderDidTapNotifications(self)
        }, for: .touchUpInside)

        updateBadge()
    }

    private func updateBadge() {
        notificationBadgeView.isHidden = notificationBadgeCount <= 0
        notificationBadgeLabel.text = "\(notificationBadgeCount)"
    }
}
