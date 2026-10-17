//
//  SplashViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 10.07.26.
//

import UIKit
import SnapKit
import FirebaseAuth

final class SplashViewController: UIViewController {

    private let backgroundWaveView = WaveBackgroundView()

    private let logoContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let circleGlowView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 90
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(red: 0.75, green: 0.85, blue: 0.98, alpha: 0.6).cgColor
        return view
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "elmiyol_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.attributedText = SplashViewController.makeTitleAttributedString()
        label.textAlignment = .center
        return label
    }()

    private let dividerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private let leftLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.55, green: 0.72, blue: 0.95, alpha: 1)
        return view
    }()

    private let rightLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.55, green: 0.72, blue: 0.95, alpha: 1)
        return view
    }()

    private let dotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1)
        view.layer.cornerRadius = 3
        return view
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elmi yolunuzda\netibarlı tərəfdaşınız."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(red: 0.35, green: 0.42, blue: 0.55, alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = UIColor(red: 0.4, green: 0.6, blue: 0.95, alpha: 1)
        indicator.hidesWhenStopped = false
        return indicator
    }()

    var onContinue: (() -> Void)?
    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator.startAnimating()
        backgroundWaveView.startAnimating()
        animateEntrance()
    }

    private func setupView() {
        view.backgroundColor = .white

        view.addSubview(backgroundWaveView)
        view.addSubview(logoContainerView)

        logoContainerView.addSubview(circleGlowView)
        logoContainerView.addSubview(logoImageView)

        view.addSubview(titleLabel)
        view.addSubview(dividerStackView)

        dividerStackView.addArrangedSubview(leftLineView)
        dividerStackView.addArrangedSubview(dotView)
        dividerStackView.addArrangedSubview(rightLineView)

        view.addSubview(subtitleLabel)
        view.addSubview(activityIndicator)
    }

    private func setupConstraints() {
        backgroundWaveView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).multipliedBy(0.55)
        }

        logoContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(140)
            make.width.height.equalTo(180)
        }

        circleGlowView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(180)
        }

        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(150)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }

        dividerStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        leftLineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(50)
        }

        rightLineView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(50)
        }

        dotView.snp.makeConstraints { make in
            make.width.height.equalTo(6)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(dividerStackView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
        }

        activityIndicator.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.centerX.equalToSuperview()
        }
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
    }

    @objc private func handleScreenTap() {
        guard !didNavigate else { return }
        didNavigate = true
        if let onContinue {
            onContinue()
        } else {
            goToNextScreen()
        }
    }

    private func animateEntrance() {
        logoContainerView.alpha = 0
        logoContainerView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        titleLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 10)
        dividerStackView.alpha = 0
        subtitleLabel.alpha = 0
        subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 10)

        UIView.animate(withDuration: 0.7,
                        delay: 0,
                        usingSpringWithDamping: 0.8,
                        initialSpringVelocity: 0.5,
                        options: .curveEaseOut) {
            self.logoContainerView.alpha = 1
            self.logoContainerView.transform = .identity
        }

        UIView.animate(withDuration: 0.5, delay: 0.25, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }

        UIView.animate(withDuration: 0.4, delay: 0.4) {
            self.dividerStackView.alpha = 1
        }

        UIView.animate(withDuration: 0.5, delay: 0.45, options: .curveEaseOut) {
            self.subtitleLabel.alpha = 1
            self.subtitleLabel.transform = .identity
        }
    }

    private func goToNextScreen() {
        if let user = FirebaseAuthService.shared.currentUser,
           let window = view.window {
            FirebaseAuthService.AuthCoordinator.route(user: user, in: window) { [weak self] error in
                self?.presentAuthError(error)
            }
            return
        }
        let onboardingVC = OnboardingFirstViewController()
        navigationController?.pushViewControllerWithFade(onboardingVC)
    }

    private static func makeTitleAttributedString() -> NSAttributedString {
        let fullString = NSMutableAttributedString()

        let elmiPart = NSAttributedString(
            string: "Elmi",
            attributes: [
                .font: UIFont.systemFont(ofSize: 44, weight: .heavy),
                .foregroundColor: UIColor(red: 0.09, green: 0.18, blue: 0.42, alpha: 1)
            ]
        )

        let yolPart = NSAttributedString(
            string: "Yol",
            attributes: [
                .font: UIFont.systemFont(ofSize: 44, weight: .heavy),
                .foregroundColor: UIColor(red: 0.24, green: 0.5, blue: 0.98, alpha: 1)
            ]
        )

        fullString.append(elmiPart)
        fullString.append(yolPart)

        return fullString
    }
}
