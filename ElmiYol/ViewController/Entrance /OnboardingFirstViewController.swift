//
//  OnboardingFirstViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 13.07.26.
//

import UIKit
import SnapKit

final class OnboardingFirstViewController: UIViewController {

    private let backgroundWaveView = WaveBackgroundView()

    private let illustrationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "onboarding_progress_illustration")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Keç", for: .normal)
        button.setTitleColor(UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 2
        control.currentPage = 0
        control.currentPageIndicatorTintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        control.pageIndicatorTintColor = UIColor(red: 0.85, green: 0.89, blue: 0.97, alpha: 1)
        return control
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = OnboardingFirstViewController.makeTitleAttributedString()
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Dissertasiya, tezis və məqalələrinizin mərhələlərini izləyin, son tarixləri qaçırmayın. Hədəflərinizə addım-addım yaxınlaşın."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Geri"
        config.baseBackgroundColor = UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1)
        config.baseForegroundColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        button.configuration = config
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Növbəti"
        config.image = UIImage(systemName: "chevron.right")
        config.imagePlacement = .trailing
        config.imagePadding = 6
        config.baseBackgroundColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 16, weight: .semibold)
            return outgoing
        }
        button.configuration = config
        return button
    }()

   
    private var didNavigate = false


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        didNavigate = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.backgroundWaveView.startAnimating()
            }
    }


    private func setupView() {
        view.backgroundColor = .white

        view.addSubview(backgroundWaveView)
        view.addSubview(illustrationImageView)
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)
        view.addSubview(nextButton)
    }

    private func setupConstraints() {
        backgroundWaveView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).multipliedBy(0.78)
        }

        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }

        illustrationImageView.snp.makeConstraints { make in
            make.top.equalTo(skipButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(340)
        }

        pageControl.snp.makeConstraints { make in
            make.top.equalTo(illustrationImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(36)
            make.trailing.equalToSuperview().offset(-36)
        }

        backButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(54)
        }

        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.trailing.equalToSuperview().offset(-24)
            make.width.equalToSuperview().multipliedBy(0.45)
            make.height.equalTo(54)
        }
    }

    private func setupActions() {
        skipButton.addAction(UIAction { [weak self] _ in
            self?.handleForwardNavigation()
        }, for: .touchUpInside)

        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        nextButton.addAction(UIAction { [weak self] _ in
            self?.handleForwardNavigation()
        }, for: .touchUpInside)
    }


    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    private func handleForwardNavigation() {
        guard !didNavigate else { return }
        didNavigate = true
        let nextVC = OnboardingSecondViewController()
        navigationController?.pushViewControllerWithFade(nextVC)
    }

    private static func makeTitleAttributedString() -> NSAttributedString {
        let fullString = NSMutableAttributedString()

        let firstLine = NSAttributedString(
            string: "İrəliləyişinizi\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )

        let secondLine = NSAttributedString(
            string: "asanlıqla izləyin",
            attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
            ]
        )

        fullString.append(firstLine)
        fullString.append(secondLine)

        return fullString
    }
}
