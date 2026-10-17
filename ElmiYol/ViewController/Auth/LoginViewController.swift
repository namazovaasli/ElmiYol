//
//  ViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 10.07.26.
//
 
import UIKit
import SnapKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Security

final class LoginViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1)
        button.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
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
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )
        if let range = text.range(of: "Yol") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
        }
        label.attributedText = attributed
        label.textAlignment = .center
        return label
    }()

    private let logoSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elmi yolunuzda etibarlı tərəfdaşınız."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Daxil ol"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesabınıza daxil olmaq üçün məlumatlarınızı daxil edin."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        label.numberOfLines = 0
        return label
    }()

    private let emailField = BaseTextField(iconSystemName: "person.fill", title: "E-poçt ünvanı", placeholder: "example@mail.com", keyboardType: .emailAddress)
    private let passwordField = BaseTextField(iconSystemName: "lock.fill", title: "Şifrə", placeholder: "Şifrənizi daxil edin", isSecure: true)

    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Şifrəni unutdunuz?", for: .normal)
        button.setTitleColor(UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()

    private let loginButton = BaseButton(title: "Daxil ol", style: .primary, showsArrow: true)

    private let registerPromptLabel: UILabel = {
        let label = UILabel()
        let text = "Hesabınız yoxdur? Qeydiyyatdan keçin"
        let attributed = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
            ]
        )
        if let range = text.range(of: "Qeydiyyatdan keçin") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .semibold), range: nsRange)
            attributed.addAttribute(.foregroundColor, value: UIColor(red: 0.16, green: 0.38, blue: 0.92, alpha: 1), range: nsRange)
        }
        label.attributedText = attributed
        label.textAlignment = .center
        return label
    }()
    private let dividerLabel: UILabel = {
        let label = UILabel()
        label.text = "və ya"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let dividerLeftLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.88, green: 0.9, blue: 0.94, alpha: 1)
        return view
    }()

    private let dividerRightLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.88, green: 0.9, blue: 0.94, alpha: 1)
        return view
    }()

    private let socialButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private let googleButton = SocialLoginButton(imageName: "google_icon", title: "Google ilə")
    private let emailCodeButton = SocialLoginButton(imageName: "envelope", title: "E-poçt linki")
    private var didNavigate = false
    private var isSubmitting = false
    private var currentAppleNonce: String?

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
        view.addSubview(backButton)
        view.addSubview(logoImageView)
        view.addSubview(logoTitleLabel)
        view.addSubview(logoSubtitleLabel)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(forgotPasswordButton)
        view.addSubview(loginButton)
        view.addSubview(registerPromptLabel)
        
        view.addSubview(dividerLeftLine)
        view.addSubview(dividerLabel)
        view.addSubview(dividerRightLine)

        socialButtonsStack.addArrangedSubview(googleButton)
        socialButtonsStack.addArrangedSubview(emailCodeButton)
        view.addSubview(socialButtonsStack)
    }

    private func setupConstraints() {
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(110)
        }

        logoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        logoSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoTitleLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoSubtitleLabel.snp.bottom).offset(36)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        emailField.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        passwordField.snp.makeConstraints { make in
            make.top.equalTo(emailField.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordField.snp.bottom).offset(30)
            make.trailing.equalToSuperview().offset(-24)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(58)
        }

        registerPromptLabel.snp.makeConstraints { make in
            make.top.equalTo(socialButtonsStack.snp.bottom).offset(28)
                make.centerX.equalToSuperview()
                make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        dividerLeftLine.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalTo(dividerLabel.snp.leading).offset(-12)
            make.height.equalTo(1)
            make.centerY.equalTo(dividerLabel)
        }

        dividerLabel.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
        }

        dividerRightLine.snp.makeConstraints { make in
            make.leading.equalTo(dividerLabel.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-24)
            make.height.equalTo(1)
            make.centerY.equalTo(dividerLabel)
        }

        socialButtonsStack.snp.makeConstraints { make in
            make.top.equalTo(dividerLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(84)
        }
    }

    private func setupValidators() {
        emailField.setValidator(.email)
        passwordField.setValidator(.required(fieldName: "Şifrə"))
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)

        loginButton.addAction(UIAction { [weak self] _ in
            self?.handleLoginTap()
        }, for: .touchUpInside)

        registerPromptLabel.isUserInteractionEnabled = true
        let registerTap = UITapGestureRecognizer(target: self, action: #selector(didTapRegister))
        registerPromptLabel.addGestureRecognizer(registerTap)

        forgotPasswordButton.addAction(UIAction { [weak self] _ in
            self?.handleForgotPassword()
        }, for: .touchUpInside)
        
        googleButton.onTap = { [weak self] in
            self?.handleGoogleLogin()
        }
        emailCodeButton.onTap = { [weak self] in
            self?.handleEmailCodeLogin()
        }
    }
    
    private func handleAppleLogin() {
        guard FirebaseAuthService.shared.isConfigured else {
            presentAuthError(FirebaseAuthServiceError.firebaseNotConfigured)
            return
        }
        guard let nonce = randomNonceString() else {
            presentAuthMessage("Təhlükəsiz giriş sorğusu yaratmaq mümkün olmadı.", title: "Xəta")
            return
        }
        currentAppleNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func handleGoogleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            presentAuthError(FirebaseAuthServiceError.firebaseNotConfigured)
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.presentAuthError(error)
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                self.presentAuthMessage("Google hesabından giriş məlumatları alınmadı.", title: "Xəta")
                return
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: user.accessToken.tokenString
            )
            self.signIn(with: credential)
        }
    }

    private func handleEmailCodeLogin() {
        let alert = UIAlertController(title: "E-poçt ilə giriş", message: "Giriş bağlantısını göndərmək üçün e-poçt ünvanınızı daxil edin.", preferredStyle: .alert)
        alert.addTextField { [weak self] field in
            field.keyboardType = .emailAddress
            field.autocapitalizationType = .none
            field.autocorrectionType = .no
            field.text = self?.emailField.value
            field.placeholder = "example@mail.com"
        }
        alert.addAction(UIAlertAction(title: "Ləğv et", style: .cancel))
        alert.addAction(UIAlertAction(title: "Bağlantı göndər", style: .default) { [weak self, weak alert] _ in
            guard let self, let email = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !email.isEmpty else {
                self?.presentAuthMessage("E-poçt ünvanınızı daxil edin.")
                return
            }
            FirebaseAuthService.shared.sendEmailSignInLink(to: email) { [weak self] error in
                guard let self else { return }
                if let error {
                    self.presentAuthError(error)
                } else {
                    self.presentAuthMessage("Giriş bağlantısı e-poçt ünvanınıza göndərildi. Bağlantını bu cihazda açın.")
                }
            }
        })
        present(alert, animated: true)
    }
    
    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }

    @objc private func didTapRegister() {
        guard !didNavigate else { return }
        didNavigate = true
        AppRouter.shared.push(.roleSelection)
    }

    private func handleLoginTap() {
        guard !isSubmitting else { return }
        let isEmailValid = emailField.validate()
        let isPasswordValid = passwordField.validate()

        guard isEmailValid, isPasswordValid else { return }
        isSubmitting = true
        FirebaseAuthService.shared.signIn(email: emailField.value, password: passwordField.value) { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(let user):
                self.routeAuthenticatedUser(user)
            case .failure(let error):
                self.presentAuthError(error)
            }
        }
    }

    private func handleForgotPassword() {
        let email = emailField.value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard emailField.validate(), !email.isEmpty else {
            presentAuthMessage("Şifrəni sıfırlamaq üçün əvvəlcə e-poçt ünvanınızı daxil edin.")
            return
        }
        FirebaseAuthService.shared.sendPasswordReset(to: email) { [weak self] error in
            guard let self else { return }
            if let error {
                self.presentAuthError(error)
            } else {
                self.presentAuthMessage("Şifrəni yeniləmək üçün təlimat e-poçtunuza göndərildi.")
            }
        }
    }

    private func signIn(with credential: AuthCredential) {
        guard !isSubmitting else { return }
        isSubmitting = true
        FirebaseAuthService.shared.signIn(with: credential) { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(let user):
                self.routeAuthenticatedUser(user)
            case .failure(let error):
                self.presentAuthError(error)
            }
        }
    }

    private func routeAuthenticatedUser(_ user: User) {
        guard let window = view.window else {
            presentAuthMessage("Tətbiq pəncərəsi tapılmadı. Yenidən cəhd edin.", title: "Xəta")
            return
        }
        FirebaseAuthService.AuthCoordinator.route(user: user, in: window) { [weak self] error in
            self?.presentAuthError(error)
        }
    }

    private func randomNonceString(length: Int = 32) -> String? {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var randomBytes = [UInt8](repeating: 0, count: length)
        guard SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes) == errSecSuccess else {
            return nil
        }
        return randomBytes.map { charset[Int($0) % charset.count] }.reduce(into: "") { $0.append($1) }
    }

    private func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8)).map { String(format: "%02x", $0) }.joined()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let nonce = currentAppleNonce,
              let tokenData = appleCredential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8) else {
            presentAuthMessage("Apple hesabından giriş məlumatları alınmadı.", title: "Xəta")
            return
        }

        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: appleCredential.fullName
        )
        currentAppleNonce = nil
        signIn(with: credential)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        currentAppleNonce = nil
        if let appleError = error as? ASAuthorizationError, appleError.code == .canceled {
            return
        }
        presentAuthError(error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? UIWindow()
    }
}
