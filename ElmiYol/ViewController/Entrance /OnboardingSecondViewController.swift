//
//  OnboardingSecondViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 14.07.26.
//

import UIKit
import SnapKit

final class OnboardingSecondViewController: UIViewController {

    private let backgroundWaveView = WaveBackgroundView()
    
    private let illustrationImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "onboarding_teacher_student_illustration")
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
        control.currentPage = 1
        control.currentPageIndicatorTintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        control.pageIndicatorTintColor = UIColor(red: 0.85, green: 0.89, blue: 0.97, alpha: 1)
        return control
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.attributedText = OnboardingSecondViewController.makeTitleAttributedString()
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Rəyləri görün, suallarınızı verin, fayl və sənədlərinizi asanlıqla paylaşın."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let featuresStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        return stack
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

    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "Başlayaq"
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
        setupFeatures()
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
        view.addSubview(featuresStackView)
        view.addSubview(backButton)
        view.addSubview(startButton)
    }

    private func setupFeatures() {
        let features: [(iconSystemName: String, label: String)] = [
            ("bubble.left.and.bubble.right.fill", "Rəylər və şərhlər"),
            ("square.and.arrow.up.fill", "Fayl paylaşımı"),
            ("bell.fill", "Bildirişlərlə\nxəbərdar olun")
        ]

        for feature in features {
            let featureView = FeatureIconView()
            featureView.configure(iconSystemName: feature.iconSystemName, label: feature.label)
            featuresStackView.addArrangedSubview(featureView)
        }
    }

    private func setupConstraints() {
        backgroundWaveView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.snp.bottom).multipliedBy(0.85)
        }

        skipButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.trailing.equalToSuperview().offset(-20)
        }

        illustrationImageView.snp.makeConstraints { make in
            make.top.equalTo(skipButton.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(320)
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

        featuresStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(70)
        }

        backButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            make.leading.equalToSuperview().offset(24)
            make.width.equalToSuperview().multipliedBy(0.35)
            make.height.equalTo(54)
        }

        startButton.snp.makeConstraints { make in
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

        startButton.addAction(UIAction { [weak self] _ in
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
        let nextVC = RoleSelectionViewController()
            navigationController?.pushViewControllerWithFade(nextVC)
    }


    private static func makeTitleAttributedString() -> NSAttributedString {
        let fullString = NSMutableAttributedString()

        let firstLine = NSAttributedString(
            string: "Elmi rəhbərlə\n",
            attributes: [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )

        let secondLine = NSAttributedString(
            string: "daim əlaqədə olun",
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

private final class FeatureIconView: UIView {

    private let iconContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(red: 0.35, green: 0.4, blue: 0.5, alpha: 1)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        addSubview(label)

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        label.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(iconSystemName: String, label labelText: String) {
        iconImageView.image = UIImage(systemName: iconSystemName)
        label.text = labelText
    }
}
