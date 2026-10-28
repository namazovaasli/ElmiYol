//
//  StudentResearchViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

struct ResearchItem {
    let id: String
    let iconSystemName: String
    let iconTint: UIColor
    let iconBackground: UIColor
    let statusText: String
    let statusTint: UIColor
    let statusBackground: UIColor
    let titleText: String
    let personText: String
    let startDateText: String
    let endDateText: String
    let progress: Double
    var personUid: String = ""
}

enum ResearchTab: Int {
    case active
    case pending
    case completed
}

final class StudentResearchViewController: UIViewController {

    private var currentTab: ResearchTab = .active {
        didSet { reloadTableView() }
    }

    private var activeItems: [ResearchItem] = []
    private var pendingItems: [ResearchItem] = []
    private var completedItems: [ResearchItem] = []
    private var displayedItems: [ResearchItem] = []

    private let scrollHeaderView = UIView()

    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.tintColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
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
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
            ]
        )
        if let range = text.range(of: "Yol") {
            let nsRange = NSRange(range, in: text)
            attributed.addAttribute(.foregroundColor, value: AppColors.primary, range: nsRange)
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
        button.tintColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        button.setImage(UIImage(systemName: "bell"), for: .normal)
        button.layer.cornerRadius = 24
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.06
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        return button
    }()

    private let notificationBadgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.25, blue: 0.3, alpha: 1)
        view.layer.cornerRadius = 9
        return view
    }()

    private let notificationBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = "3"
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tədqiqatlarım"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private lazy var activeTabButton = ResearchTabButton(title: "Aktiv")
    private lazy var pendingTabButton = ResearchTabButton(title: "Gözləyən")
    private lazy var completedTabButton = ResearchTabButton(title: "Tamamlanmış")

    private let tabsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.register(ResearchCardCell.self, forCellReuseIdentifier: ResearchCardCell.reuseIdentifier)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        return tv
    }()

    private let addResearchButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.attributedTitle = AttributedString("Yeni tədqiqat əlavə et", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]))
        config.baseForegroundColor = AppColors.primary
        button.configuration = config
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppColors.primary.cgColor
        return button
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.delaysContentTouches = false
        sv.canCancelContentTouches = true
        return sv
    }()
    private let contentView = UIView()

    private var didNavigate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.97, green: 0.98, blue: 1, alpha: 1)
        loadSampleData()
        setupView()
        setupConstraints()
        setupActions()
        updateTabsAppearance()
        reloadTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        logoStack.addArrangedSubview(logoImageView)
        logoStack.addArrangedSubview(logoTitleLabel)

        contentView.addSubview(menuButton)
        contentView.addSubview(logoStack)
        contentView.addSubview(notificationButton)
        notificationButton.addSubview(notificationBadgeView)
        notificationBadgeView.addSubview(notificationBadgeLabel)

        contentView.addSubview(titleLabel)

        tabsStackView.addArrangedSubview(activeTabButton)
        tabsStackView.addArrangedSubview(pendingTabButton)
        tabsStackView.addArrangedSubview(completedTabButton)
        contentView.addSubview(tabsStackView)

        contentView.addSubview(tableView)
        contentView.addSubview(addResearchButton)
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        logoStack.snp.makeConstraints { make in
            make.centerY.equalTo(menuButton)
            make.centerX.equalToSuperview()
        }

        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        notificationButton.snp.makeConstraints { make in
            make.centerY.equalTo(menuButton)
            make.trailing.equalToSuperview().offset(-20)
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

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(menuButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        tabsStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(tabsStackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }

        addResearchButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        menuButton.addAction(UIAction { [weak self] _ in
            self?.handleMenuTap()
        }, for: .touchUpInside)

        notificationButton.addAction(UIAction { [weak self] _ in
            self?.handleNotificationsTap()
        }, for: .touchUpInside)

        activeTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .active
            self?.updateTabsAppearance()
        }, for: .touchUpInside)

        pendingTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .pending
            self?.updateTabsAppearance()
        }, for: .touchUpInside)

        completedTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .completed
            self?.updateTabsAppearance()
        }, for: .touchUpInside)

        addResearchButton.addAction(UIAction { [weak self] _ in
            self?.handleAddResearchTap()
        }, for: .touchUpInside)

        tableView.dataSource = self
        tableView.delegate = self
    }

    private func handleMenuTap() {
        presentSideMenu(current: .research, delegate: self)
    }

    private func handleNotificationsTap() {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: .research)
    }

    private func handleAddResearchTap() {
        let newResearchVC = NewResearchViewController()
        newResearchVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(newResearchVC)
    }
    
    
    private func loadSampleData() {
        activeItems = [
            ResearchItem(
                id: "1",
                iconSystemName: "doc.text.fill",
                iconTint: AppColors.green,
                iconBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
                statusText: "Aktiv",
                statusTint: AppColors.green,
                statusBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
                titleText: "Süni intellektin təhsildə tətbiqi imkanları",
                personText: "Prof. Dr. İlqar Məmmədov",
                startDateText: "10 May 2025",
                endDateText: "10 Avq 2025",
                progress: 0.65
            ),
            ResearchItem(
                id: "2",
                iconSystemName: "chart.xyaxis.line",
                iconTint: UIColor(red: 0.55, green: 0.35, blue: 0.85, alpha: 1),
                iconBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
                statusText: "Aktiv",
                statusTint: AppColors.green,
                statusBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
                titleText: "Mobil tətbiqlərdə təhlükəsizlik yanaşmaları",
                personText: "Prof. Dr. Aygün Əliyeva",
                startDateText: "05 May 2025",
                endDateText: "05 Sen 2025",
                progress: 0.40
            )
        ]

        pendingItems = [
            ResearchItem(
                id: "3",
                iconSystemName: "hourglass",
                iconTint: UIColor(red: 0.9, green: 0.6, blue: 0.15, alpha: 1),
                iconBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
                statusText: "Gözləyən",
                statusTint: UIColor(red: 0.9, green: 0.6, blue: 0.15, alpha: 1),
                statusBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
                titleText: "Big Data analitikası ilə tələbə performansının izlənməsi",
                personText: "Prof. Dr. İlqar Məmmədov",
                startDateText: "Gözlənilir",
                endDateText: "-",
                progress: 0.0
            )
        ]

        completedItems = [
            ResearchItem(
                id: "4",
                iconSystemName: "checkmark.seal.fill",
                iconTint: AppColors.primary,
                iconBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
                statusText: "Tamamlanmış",
                statusTint: AppColors.primary,
                statusBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
                titleText: "Elektron təhsil platformalarının müqayisəli təhlili",
                personText: "Prof. Dr. Aygün Əliyeva",
                startDateText: "01 Yan 2025",
                endDateText: "01 Apr 2025",
                progress: 1.0
            )
        ]
    }

    private func updateTabsAppearance() {
        activeTabButton.setSelected(currentTab == .active)
        pendingTabButton.setSelected(currentTab == .pending)
        completedTabButton.setSelected(currentTab == .completed)
    }

    private func reloadTableView() {
        switch currentTab {
        case .active:
            displayedItems = activeItems
        case .pending:
            displayedItems = pendingItems
        case .completed:
            displayedItems = completedItems
        }
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.snp.updateConstraints { make in
            make.height.equalTo(max(tableView.contentSize.height, 1))
        }
    }
}

extension StudentResearchViewController: SideMenuViewControllerDelegate {}
extension StudentResearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ResearchCardCell.reuseIdentifier, for: indexPath) as? ResearchCardCell else {
            return UITableViewCell()
        }
        cell.configure(with: displayedItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !didNavigate else { return }
        didNavigate = true
        let selectedItem = displayedItems[indexPath.row]
        let detailVC = ResearchDetailViewController(item: selectedItem)
        detailVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(detailVC)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        180
    }
}


private final class ResearchTabButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        configureAppearance(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureAppearance(title: String) {
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppColors.surface
        config.baseForegroundColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        self.configuration = config
    }

    func setSelected(_ selected: Bool) {
        var config = configuration
        config?.baseBackgroundColor = selected ? AppColors.primary : AppColors.surface
        config?.baseForegroundColor = selected ? .white : UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        configuration = config
    }
}


private final class ResearchCardCell: UITableViewCell {

    static let reuseIdentifier = "ResearchCardCell"

    private let cardContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    private let iconContainerView = UIView()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let statusBadgeView = UIView()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        label.numberOfLines = 2
        return label
    }()

    private let personLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()

    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()

    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(red: 0.55, green: 0.6, blue: 0.68, alpha: 1)
        return label
    }()

    private let progressCaptionLabel: UILabel = {
        let label = UILabel()
        label.text = "İrəliləyiş"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(red: 0.45, green: 0.5, blue: 0.6, alpha: 1)
        return label
    }()

    private let progressTrackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.9, green: 0.92, blue: 0.96, alpha: 1)
        view.layer.cornerRadius = 4
        return view
    }()

    private let progressFillView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.primary
        view.layer.cornerRadius = 4
        return view
    }()

    private let progressPercentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.16, blue: 0.24, alpha: 1)
        return label
    }()

    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "chevron.right")
        iv.tintColor = UIColor(red: 0.6, green: 0.65, blue: 0.75, alpha: 1)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private var progressValue: CGFloat = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setupHierarchy()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        contentView.addSubview(cardContainerView)
        cardContainerView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        statusBadgeView.addSubview(statusLabel)
        cardContainerView.addSubview(statusBadgeView)
        cardContainerView.addSubview(chevronImageView)
        cardContainerView.addSubview(titleLabel)
        cardContainerView.addSubview(personLabel)
        cardContainerView.addSubview(startDateLabel)
        cardContainerView.addSubview(endDateLabel)
        cardContainerView.addSubview(progressCaptionLabel)
        cardContainerView.addSubview(progressPercentLabel)
        cardContainerView.addSubview(progressTrackView)
        progressTrackView.addSubview(progressFillView)
    }

    private func setupConstraints() {
        cardContainerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview()
        }

        iconContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        statusBadgeView.snp.makeConstraints { make in
            make.top.equalTo(iconContainerView)
            make.leading.equalTo(iconContainerView.snp.trailing).offset(12)
            make.height.equalTo(24)
        }

        statusLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        chevronImageView.snp.makeConstraints { make in
            make.centerY.equalTo(iconContainerView)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(16)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(statusBadgeView.snp.bottom).offset(12)
            make.leading.equalTo(iconContainerView)
            make.trailing.equalToSuperview().offset(-20)
        }

        personLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        startDateLabel.snp.makeConstraints { make in
            make.top.equalTo(personLabel.snp.bottom).offset(12)
            make.leading.equalTo(titleLabel)
        }

        endDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(startDateLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        progressCaptionLabel.snp.makeConstraints { make in
            make.top.equalTo(startDateLabel.snp.bottom).offset(16)
            make.leading.equalTo(titleLabel)
        }

        progressPercentLabel.snp.makeConstraints { make in
            make.centerY.equalTo(progressCaptionLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        progressTrackView.snp.makeConstraints { make in
            make.top.equalTo(progressCaptionLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(8)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        progressFillView.frame = CGRect(
            x: 0, y: 0,
            width: progressTrackView.bounds.width * progressValue,
            height: progressTrackView.bounds.height
        )
    }

    func configure(with item: ResearchItem) {
        iconContainerView.backgroundColor = item.iconBackground
        iconContainerView.layer.cornerRadius = 14
        iconImageView.image = UIImage(systemName: item.iconSystemName)
        iconImageView.tintColor = item.iconTint

        statusLabel.text = item.statusText
        statusLabel.textColor = item.statusTint
        statusBadgeView.backgroundColor = item.statusBackground
        statusBadgeView.layer.cornerRadius = 12

        titleLabel.text = item.titleText
        personLabel.text = item.personText
        startDateLabel.text = "📅 Başlama tarixi: \(item.startDateText)"
        endDateLabel.text = "Bitmə tarixi: \(item.endDateText)"

        progressValue = CGFloat(item.progress)
        progressPercentLabel.text = "\(Int(item.progress * 100))%"
        setNeedsLayout()
    }
}
