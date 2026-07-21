//
//  SupervisorResearchViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

private struct SupervisorResearchItem {
    let studentName: String
    let universityInfo: String
    let title: String
    let deadline: String
    let statusText: String
    let statusTint: UIColor
    let statusBackground: UIColor
    let progress: Double
    let updatedText: String
    let avatarColor: UIColor
}

final class SupervisorResearchViewController: UIViewController {
    
    private var didNavigate = false
    private var allItems: [SupervisorResearchItem] = []
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.delaysContentTouches = false
        sv.canCancelContentTouches = true
        return sv
    }()
    private let contentView = UIView()
    
    private let headerView = TabScreenHeaderView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tədqiqatlar"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "line.3.horizontal.decrease")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.attributedTitle = AttributedString("Filtr", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.baseForegroundColor = AppColors.primary
        config.background.strokeColor = AppColors.primary
        config.background.strokeWidth = 1
        config.background.cornerRadius = 20
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14)
        button.configuration = config
        return button
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tələbələrinizin tədqiqat işlərini izləyin və idarə edin."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()
    
    private let statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 10
        return stack
    }()
    
    private let searchField: UITextField = {
        let field = UITextField()
        field.placeholder = "Axtarış et..."
        field.font = .systemFont(ofSize: 15)
        field.backgroundColor = .white
        field.layer.cornerRadius = 14
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        return field
    }()
    
    private let sortButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.attributedTitle = AttributedString("Son yenilənən", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 13, weight: .medium)
        ]))
        config.baseForegroundColor = AppColors.textSecondary
        button.configuration = config
        return button
    }()
    
    private let listStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        headerView.delegate = self
        loadSampleData()
        setupView()
        setupConstraints()
        reloadList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(filterButton)
        contentView.addSubview(subtitleLabel)
        
        for (color, value, caption) in [
            (UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1), "6", "Aktiv"),
            (UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1), "3", "Gözləyən"),
            (UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1), "4", "Tamamlanmış")
        ] {
            statsStackView.addArrangedSubview(makeSummaryCard(background: color, value: value, caption: caption))
        }
        contentView.addSubview(statsStackView)
        
        contentView.addSubview(searchField)
        contentView.addSubview(sortButton)
        contentView.addSubview(listStackView)
    }
    
    private func makeSummaryCard(background: UIColor, value: String, caption: String) -> UIView {
        let card = UIView()
        card.backgroundColor = background
        card.layer.cornerRadius = 16
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = AppColors.textPrimary
        let captionLabel = UILabel()
        captionLabel.text = caption
        captionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        captionLabel.textColor = AppColors.textSecondary
        let subLabel = UILabel()
        subLabel.text = "tədqiqat"
        subLabel.font = .systemFont(ofSize: 11)
        subLabel.textColor = AppColors.textMuted
        card.addSubview(valueLabel)
        card.addSubview(captionLabel)
        card.addSubview(subLabel)
        valueLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(14)
        }
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.leading.equalTo(valueLabel)
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(1)
            make.leading.equalTo(valueLabel)
            make.bottom.equalToSuperview().offset(-14)
        }
        return card
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        headerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        searchField.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(sortButton.snp.leading).offset(-12)
            make.height.equalTo(48)
        }
        sortButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchField)
            make.trailing.equalToSuperview().offset(-20)
        }
        listStackView.snp.makeConstraints { make in
            make.top.equalTo(searchField.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }
    
    private func loadSampleData() {
        allItems = [
            SupervisorResearchItem(
                studentName: "Əsli Namazova", universityInfo: "BDU • Kompüter Elmləri • 1-ci kurs",
                title: "Süni intellektin təhsildə tətbiqi imkanları",
                deadline: "15 İyun 2025", statusText: "Aktiv",
                statusTint: AppColors.green, statusBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
                progress: 0.65, updatedText: "2 gün əvvəl",
                avatarColor: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
            ),
            SupervisorResearchItem(
                studentName: "Nigar Əliyeva", universityInfo: "BDU • Kompüter Elmləri • 2-ci kurs",
                title: "Mobil tətbiqlərdə təhlükəsizlik yanaşmaları",
                deadline: "20 İyun 2025", statusText: "Gözləyir",
                statusTint: AppColors.orange, statusBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
                progress: 0.40, updatedText: "5 gün əvvəl",
                avatarColor: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1)
            ),
            SupervisorResearchItem(
                studentName: "Reşad Hüseynli", universityInfo: "BDU • Kompüter Elmləri • 1-ci kurs",
                title: "Elektron təhsil platformalarının müqayisəli təhlili",
                deadline: "01 Apr 2025", statusText: "Tamamlanmış",
                statusTint: AppColors.purple, statusBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
                progress: 1.0, updatedText: "1 həftə əvvəl",
                avatarColor: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1)
            )
        ]
    }
    
    private func reloadList() {
        listStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for item in allItems {
            let row = SupervisorResearchCardView(item: item)
            
            row.onTap = { [weak self] in
                guard let self = self, !self.didNavigate else { return }
                self.didNavigate = true
                
                
                let researchItem = ResearchItem(
                    id: item.title,
                    iconSystemName: "doc.text.fill",
                    iconTint: item.statusTint,
                    iconBackground: item.statusBackground,
                    statusText: item.statusText,
                    statusTint: item.statusTint,
                    statusBackground: item.statusBackground,
                    titleText: item.title,
                    personText: item.studentName,
                    startDateText: item.updatedText,
                    endDateText: item.deadline,
                    progress: item.progress
                )

                let detailVC = ResearchDetailViewController(item: researchItem)
                detailVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewControllerWithFade(detailVC)
            }
            
            listStackView.addArrangedSubview(row)
        }
    }


}
extension SupervisorResearchViewController: SideMenuViewControllerDelegate {
    func sideMenu(_ menu: SideMenuViewController, didSelectTabAt index: Int) {
        tabBarController?.selectedIndex = index
    }

    func sideMenuDidSelectNotifications(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let notificationsVC = NotificationsViewController()
        notificationsVC.previousRoute = .home
        navigationController?.pushViewControllerWithFade(notificationsVC)
    }

    func sideMenuDidSelectSettings(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let settingsVC = SettingsViewController()
        navigationController?.pushViewControllerWithFade(settingsVC)
    }

    func sideMenuDidSelectHelp(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let helpVC = HelpSupportViewController()
        navigationController?.pushViewControllerWithFade(helpVC)
    }

    func sideMenuDidSelectPrivacy(_ menu: SideMenuViewController) {
        guard !didNavigate else { return }
        didNavigate = true
        let privacyVC = PrivacySecurityViewController()
        navigationController?.pushViewControllerWithFade(privacyVC)
    }

    func sideMenuDidSelectLogout(_ menu: SideMenuViewController) {
        presentLogoutConfirmation()
    }
}

extension SupervisorResearchViewController: TabScreenHeaderViewDelegate {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView) {
        presentSideMenu(current: .research, delegate: self)
    }

    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView) {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .research)
    }
}

private final class SupervisorResearchCardView: UIView {
    
    var onTap: (() -> Void)?
    
    private let progressFillView = UIView()
    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()
    private var progressValue: CGFloat = 0

    init(item: SupervisorResearchItem) {
        super.init(frame: .zero)
        progressValue = CGFloat(item.progress)
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = AppColors.cardShadow
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12

        let avatarView = UIView()
        avatarView.backgroundColor = item.avatarColor
        avatarView.layer.cornerRadius = 24
        let avatarIcon = UIImageView(image: UIImage(systemName: "person.fill"))
        avatarIcon.tintColor = AppColors.primary
        avatarView.addSubview(avatarIcon)
        avatarIcon.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(22) }

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.numberOfLines = 2

        let studentLabel = UILabel()
        studentLabel.text = item.studentName
        studentLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        studentLabel.textColor = AppColors.textPrimary

        let uniLabel = UILabel()
        uniLabel.text = item.universityInfo
        uniLabel.font = .systemFont(ofSize: 12)
        uniLabel.textColor = AppColors.textSecondary

        let deadlineLabel = UILabel()
        deadlineLabel.text = "📅 Son tarix: \(item.deadline)"
        deadlineLabel.font = .systemFont(ofSize: 12)
        deadlineLabel.textColor = AppColors.textMuted

        let statusBadge = UILabel()
        statusBadge.text = "  • \(item.statusText)  "
        statusBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        statusBadge.textColor = item.statusTint
        statusBadge.backgroundColor = item.statusBackground
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true

        let progressCaption = UILabel()
        progressCaption.text = "İrəliləyiş"
        progressCaption.font = .systemFont(ofSize: 12)
        progressCaption.textColor = AppColors.textSecondary

        let progressLabel = UILabel()
        progressLabel.text = "\(Int(item.progress * 100))%"
        progressLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        progressLabel.textColor = AppColors.textPrimary

        let updatedLabel = UILabel()
        updatedLabel.text = "Yeniləndi: \(item.updatedText)"
        updatedLabel.font = .systemFont(ofSize: 11)
        updatedLabel.textColor = AppColors.textMuted

        progressFillView.backgroundColor = AppColors.primary
        progressFillView.layer.cornerRadius = 4

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted

        addSubview(avatarView)
        addSubview(titleLabel)
        addSubview(studentLabel)
        addSubview(uniLabel)
        addSubview(deadlineLabel)
        addSubview(statusBadge)
        addSubview(progressCaption)
        addSubview(progressLabel)
        addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
        addSubview(updatedLabel)
        addSubview(chevron)

        avatarView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(48)
        }
        statusBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }
        chevron.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(14)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        studentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        uniLabel.snp.makeConstraints { make in
            make.top.equalTo(studentLabel.snp.bottom).offset(2)
            make.leading.equalTo(studentLabel)
        }
        deadlineLabel.snp.makeConstraints { make in
            make.top.equalTo(uniLabel.snp.bottom).offset(8)
            make.leading.equalTo(studentLabel)
        }
        progressCaption.snp.makeConstraints { make in
            make.top.equalTo(deadlineLabel.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
        }
        progressLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressCaption)
            make.trailing.equalToSuperview().offset(-16)
        }
        progressTrackView.snp.makeConstraints { make in
            make.top.equalTo(progressCaption.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(8)
        }
        updatedLabel.snp.makeConstraints { make in
            make.top.equalTo(progressTrackView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
        }
        setupTapGesture()
    }
    
    private func setupTapGesture() {
           let tap = UITapGestureRecognizer(target: self, action: #selector(handleCardTap))
           self.addGestureRecognizer(tap)
           self.isUserInteractionEnabled = true
       }
       
       @objc private func handleCardTap() {
           onTap?()
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressFillView.frame = CGRect(
            x: 0, y: 0,
            width: progressTrackView.bounds.width * progressValue,
            height: progressTrackView.bounds.height
        )
    }
}
