//
//  SocialLoginButton.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 17.07.26.
//


import UIKit
import SnapKit

final class SocialLoginButton: UIView {

    var onTap: (() -> Void)?

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1).cgColor
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    init(iconSystemName: String? = nil, imageName: String? = nil, title: String) {
        super.init(frame: .zero)

        if let iconSystemName = iconSystemName {
            iconImageView.image = UIImage(systemName: iconSystemName)
            iconImageView.tintColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        } else if let imageName = imageName {
            iconImageView.image = UIImage(named: imageName)
        }
        titleLabel.text = title

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
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
    }

    private func setupConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(26)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(4)
            make.trailing.equalToSuperview().offset(-4)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    @objc private func didTap() {
        onTap?()
    }
}
