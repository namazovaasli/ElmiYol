//
//  HelpSupportViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 21.07.26.
//

import UIKit
import SnapKit

final class HelpSupportViewController: UIViewController {

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
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Kömək və dəstək"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tez-tez verilən suallar və əlaqə məlumatları."
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        setupView()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        let faqCard = makeFAQCard()
        contentView.addSubview(faqCard)

        let contactCard = makeContactCard()
        contentView.addSubview(contactCard)

        faqCard.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        contactCard.snp.makeConstraints { make in
            make.top.equalTo(faqCard.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        backButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.handleBackTap()
        }, for: .touchUpInside)
    }

    private func makeFAQCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = AppColors.cardShadow
        card.layer.shadowOpacity = 0.04
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.layer.shadowRadius = 12

        let header = UILabel()
        header.text = "Tez-tez verilən suallar"
        header.font = .systemFont(ofSize: 17, weight: .bold)
        header.textColor = AppColors.textPrimary
        card.addSubview(header)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        card.addSubview(stack)

        for (question, answer) in [
            ("Görüş necə yaradılır?", "Görüşlər bölməsində «Yeni görüş» düyməsinə basın və formu doldurun."),
            ("Tədqiqat planını necə yükləyirəm?", "Tədqiqat detalları ekranından fayl əlavə edə bilərsiniz."),
            ("Mesajlara haradan cavab verirəm?", "Mesajlar siyahısından istifadəçini seçib söhbət ekranına keçin.")
        ] {
            stack.addArrangedSubview(makeFAQItem(question: question, answer: answer))
        }

        header.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        stack.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
        }
        return card
    }

    private func makeFAQItem(question: String, answer: String) -> UIView {
        let container = UIView()
        let qLabel = UILabel()
        qLabel.text = question
        qLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        qLabel.textColor = AppColors.textPrimary
        qLabel.numberOfLines = 0

        let aLabel = UILabel()
        aLabel.text = answer
        aLabel.font = .systemFont(ofSize: 13)
        aLabel.textColor = AppColors.textSecondary
        aLabel.numberOfLines = 0

        container.addSubview(qLabel)
        container.addSubview(aLabel)
        qLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        aLabel.snp.makeConstraints { make in
            make.top.equalTo(qLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return container
    }

    private func makeContactCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        card.layer.cornerRadius = 20

        let title = UILabel()
        title.text = "Dəstək komandası"
        title.font = .systemFont(ofSize: 16, weight: .bold)
        title.textColor = AppColors.textPrimary

        let email = UILabel()
        email.text = "✉ support@elmiyol.az"
        email.font = .systemFont(ofSize: 14)
        email.textColor = AppColors.textSecondary

        let phone = UILabel()
        phone.text = "📞 +994 12 123 45 67"
        phone.font = .systemFont(ofSize: 14)
        phone.textColor = AppColors.textSecondary

        card.addSubview(title)
        card.addSubview(email)
        card.addSubview(phone)

        title.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
        }
        email.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        phone.snp.makeConstraints { make in
            make.top.equalTo(email.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        return card
    }

    private func handleBackTap() {
        guard !didNavigate else { return }
        didNavigate = true
        navigationController?.popViewControllerWithFade()
    }
}
