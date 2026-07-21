//
//  RoleSelectionViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 15.07.26.
//

import UIKit
import SnapKit

final class RoleSelectionViewController: UIViewController {

    private var selectedRole: UserRole = .student {
        didSet { updateSelection() }
    }

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "elmiyol_logo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Rolunuzu seçin"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "ElmiYol-da fəaliyyətinizə uyğun rolunuzu seçərək davam edin."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let studentCardView = RoleCardView(
        image: UIImage(named: "role_student_illustration"),
        badgeIcon: "graduationcap.fill",
        badgeTint: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1),
        badgeBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
        titleText: "Magistr tələbəsi",
        descriptionText: "Tədqiqatlarınızı idarə edin, məqalə və dissertasiya prosesinizi izləyin."
    )

    private let supervisorCardView = RoleCardView(
        image: UIImage(named: "role_supervisor_illustration"),
        badgeIcon: "person.fill",
        badgeTint: UIColor(red: 0.13, green: 0.55, blue: 0.4, alpha: 1),
        badgeBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
        titleText: "Elmi rəhbər",
        descriptionText: "Tələbələrin işlərini idarə edin, rəylər verin və təsdiqləmə əməliyyatlarını həyata keçirin."
    )

    private let securityContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        view.layer.cornerRadius = 18
        return view
    }()

    private let shieldIconView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        return view
    }()

    private let shieldImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark.shield.fill")
        iv.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let securityTextStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()

    private let securityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Təhlükəsiz və etibarlı"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let securityDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Məlumatlarınız tam təhlükəsizdir və yalnız sizə məxsusdur."
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let lockImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.fill")
        iv.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    private let loginPromptLabel: UILabel = {
        let label = UILabel()
        let text = "Hesabınız var? Daxil ol"
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
    
    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        setupView()
        setupConstraints()
        setupActions()
        updateSelection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    private func setupView() {
        view.addSubview(iconImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(studentCardView)
        view.addSubview(supervisorCardView)
        view.addSubview(securityContainerView)
        view.addSubview(loginPromptLabel)
        securityContainerView.addSubview(shieldIconView)
        shieldIconView.addSubview(shieldImageView)

        securityTextStack.addArrangedSubview(securityTitleLabel)
        securityTextStack.addArrangedSubview(securityDescriptionLabel)
        securityContainerView.addSubview(securityTextStack)
        securityContainerView.addSubview(lockImageView)
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(36)
            make.trailing.equalToSuperview().offset(-36)
        }

        studentCardView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(view.snp.centerX).offset(-6)
            make.height.equalTo(430)
        }

        supervisorCardView.snp.makeConstraints { make in
            make.top.equalTo(studentCardView)
            make.leading.equalTo(view.snp.centerX).offset(6)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(430)
        }

        securityContainerView.snp.makeConstraints { make in
            make.top.equalTo(studentCardView.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        loginPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(securityContainerView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        
        shieldIconView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        shieldImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        lockImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(22)
        }

        securityTextStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(shieldIconView.snp.trailing).offset(12)
            make.trailing.equalTo(lockImageView.snp.leading).offset(-12)
            make.bottom.equalToSuperview().offset(-16)
        }
    }

    private func setupActions() {
        let studentTap = UITapGestureRecognizer(target: self, action: #selector(didTapStudentCard))
        studentCardView.addGestureRecognizer(studentTap)
        studentCardView.isUserInteractionEnabled = true

        let supervisorTap = UITapGestureRecognizer(target: self, action: #selector(didTapSupervisorCard))
        supervisorCardView.addGestureRecognizer(supervisorTap)
        supervisorCardView.isUserInteractionEnabled = true

        studentCardView.onArrowTapped = { [weak self] in
            self?.selectedRole = .student
            self?.navigateToRegister(for: .student)
        }
        loginPromptLabel.isUserInteractionEnabled = true
        let loginTap = UITapGestureRecognizer(target: self, action: #selector(didTapLogin))
        loginPromptLabel.addGestureRecognizer(loginTap)
        
        supervisorCardView.onArrowTapped = { [weak self] in
            self?.selectedRole = .supervisor
            self?.navigateToRegister(for: .supervisor)
        }
    }
    @objc private func didTapLogin() {
        guard !didNavigate else { return }
        didNavigate = true
        AppRouter.shared.push(.login)
    }
    
    @objc private func didTapStudentCard() {
        selectedRole = .student
    }

    @objc private func didTapSupervisorCard() {
        selectedRole = .supervisor
    }

    private func updateSelection() {
        studentCardView.setSelected(selectedRole == .student)
        supervisorCardView.setSelected(selectedRole == .supervisor)
    }

    private func navigateToRegister(for role: UserRole) {
        guard !didNavigate else { return }
        didNavigate = true
        switch role {
        case .student:
            AppRouter.shared.push(.studentRegister)
        case .supervisor:
            AppRouter.shared.push(.supervisorRegister)
        }
    }
}

private final class RoleCardView: UIView {

    var onArrowTapped: (() -> Void)?

    private let avatarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        return view
    }()

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let checkmarkBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        view.layer.cornerRadius = 16
        return view
    }()

    private let checkmarkImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "checkmark")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let badgeContainerView = UIView()

    private let badgeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let arrowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        view.layer.cornerRadius = 12
        return view
    }()

    private let arrowImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "arrow.right")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    init(image: UIImage?, badgeIcon: String, badgeTint: UIColor, badgeBackground: UIColor, titleText: String, descriptionText: String) {
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = 22
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1).cgColor
        clipsToBounds = true

        avatarImageView.image = image
        badgeImageView.image = UIImage(systemName: badgeIcon)
        badgeImageView.tintColor = badgeTint
        badgeContainerView.backgroundColor = badgeBackground
        titleLabel.text = titleText
        descriptionLabel.text = descriptionText
        arrowImageView.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)

        setupHierarchy()
        setupConstraints()

        checkmarkBadgeView.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(avatarBackgroundView)
        avatarBackgroundView.addSubview(avatarImageView)
        addSubview(checkmarkBadgeView)
        checkmarkBadgeView.addSubview(checkmarkImageView)
        addSubview(badgeContainerView)
        badgeContainerView.addSubview(badgeImageView)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        addSubview(arrowContainerView)
        arrowContainerView.addSubview(arrowImageView)

        arrowContainerView.isUserInteractionEnabled = true
        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(didTapArrow))
        arrowContainerView.addGestureRecognizer(arrowTap)
    }

    private func setupConstraints() {
        avatarBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(120)
        }

        avatarImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        checkmarkBadgeView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(32)
        }

        checkmarkImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        badgeContainerView.snp.makeConstraints { make in
            make.top.equalTo(avatarBackgroundView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(44)
        }

        badgeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(22)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(badgeContainerView.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        arrowContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }

        arrowImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarBackgroundView.layer.cornerRadius = avatarBackgroundView.bounds.width / 2
        badgeContainerView.layer.cornerRadius = badgeContainerView.bounds.width / 2
    }

    @objc private func didTapArrow() {
        onArrowTapped?()
    }

    func setSelected(_ selected: Bool) {
        layer.borderColor = selected
            ? UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1).cgColor
            : UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1).cgColor
        layer.borderWidth = selected ? 2 : 1
        checkmarkBadgeView.isHidden = !selected
        arrowContainerView.backgroundColor = selected
            ? UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
            : UIColor(red: 0.93, green: 0.95, blue: 0.99, alpha: 1)
        arrowImageView.tintColor = selected
            ? UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
            : UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
    }
}
