//
//  StudentMeetingsViewController.swift
//  ElmiYol
//
//  Created by Əsli Namazova on 19.07.26.
//

import UIKit
import SnapKit

private enum MeetingsTab: Int {
    case upcoming
    case past
    case scheduled
}

private struct MeetingItem {
    let sectionTitle: String
    let day: String
    let monthYear: String
    let weekday: String
    let weekdayTint: UIColor
    let weekdayBackground: UIColor
    let title: String
    let person: String
    let description: String
    let timeRange: String
    let mode: String
    let statusText: String
    let statusTint: UIColor
    let statusBackground: UIColor
}

class StudentMeetingsViewController: UIViewController {

    var notificationsOrigin: NotificationsOrigin = .meetings

    private var currentTab: MeetingsTab = .upcoming
    private var didNavigate = false

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
        label.text = "Görüşlər"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = AppColors.textPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Elmi rəhbərinizlə görüşlərinizi izləyin və idarə edin."
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 0
        return label
    }()

    private let newMeetingButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "plus")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.cornerStyle = .capsule
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString("Yeni görüş", attributes: AttributeContainer([
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold)
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        button.configuration = config
        return button
    }()

    private lazy var upcomingTabButton = PillTabButton(title: "Yaxın görüşlər")
    private lazy var pastTabButton = PillTabButton(title: "Keçmiş görüşlər")
    private lazy var scheduledTabButton = PillTabButton(title: "Planlaşdırılanlar")

    private let tabsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private let meetingsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()

    private let calendarCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.shadowColor = AppColors.cardShadow
        view.layer.shadowOpacity = 0.04
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 12
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        headerView.delegate = self
        setupView()
        setupConstraints()
        setupActions()
        reloadMeetings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didNavigate = false
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.contentInsetAdjustmentBehavior = .always
        scrollView.addSubview(contentView)

        contentView.addSubview(headerView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(newMeetingButton)
        contentView.addSubview(subtitleLabel)

        tabsStackView.addArrangedSubview(upcomingTabButton)
        tabsStackView.addArrangedSubview(pastTabButton)
        tabsStackView.addArrangedSubview(scheduledTabButton)
        contentView.addSubview(tabsStackView)
        contentView.addSubview(meetingsStackView)
        contentView.addSubview(calendarCardView)

        setupCalendarCard()
    }

    private func setupCalendarCard() {
        let monthLabel = UILabel()
        monthLabel.text = "May 2025"
        monthLabel.font = .systemFont(ofSize: 16, weight: .bold)
        monthLabel.textColor = AppColors.textPrimary

        let prevButton = UIButton(type: .system)
        prevButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        prevButton.tintColor = AppColors.textMuted

        let nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = AppColors.textMuted

        let daysStack = UIStackView()
        daysStack.axis = .horizontal
        daysStack.distribution = .fillEqually

        let days = ["B.e\n19", "Ç.a\n20", "Ç\n21", "C.a\n22", "C\n23", "Ş\n24", "B\n25"]
        for (index, day) in days.enumerated() {
            let dayView = makeCalendarDayView(text: day, isSelected: index == 4)
            daysStack.addArrangedSubview(dayView)
        }

        let legendStack = UIStackView()
        legendStack.axis = .horizontal
        legendStack.spacing = 12
        legendStack.distribution = .fillEqually
        for (color, title) in [
            (AppColors.primary, "Təsdiqləndi"),
            (AppColors.orange, "Gözləyir"),
            (AppColors.green, "Tamamlandı"),
            (AppColors.textMuted, "Ləğv edildi")
        ] {
            legendStack.addArrangedSubview(makeLegendItem(color: color, title: title))
        }

        calendarCardView.addSubview(monthLabel)
        calendarCardView.addSubview(prevButton)
        calendarCardView.addSubview(nextButton)
        calendarCardView.addSubview(daysStack)
        calendarCardView.addSubview(legendStack)

        monthLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(20)
        }
        nextButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalToSuperview().offset(-20)
        }
        prevButton.snp.makeConstraints { make in
            make.centerY.equalTo(monthLabel)
            make.trailing.equalTo(nextButton.snp.leading).offset(-12)
        }
        daysStack.snp.makeConstraints { make in
            make.top.equalTo(monthLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }
        legendStack.snp.makeConstraints { make in
            make.top.equalTo(daysStack.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func makeCalendarDayView(text: String, isSelected: Bool) -> UIView {
        let container = UIView()
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: isSelected ? .bold : .regular)
        label.textColor = isSelected ? .white : AppColors.textSecondary
        label.textAlignment = .center
        label.numberOfLines = 2
        container.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(4) }
        if isSelected {
            container.backgroundColor = AppColors.primary
            container.layer.cornerRadius = 12
        }
        return container
    }

    private func makeLegendItem(color: UIColor, title: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 3
        dot.snp.makeConstraints { $0.width.height.equalTo(6) }
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = AppColors.textMuted
        stack.addArrangedSubview(dot)
        stack.addArrangedSubview(label)
        return stack
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        newMeetingButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        tabsStackView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        meetingsStackView.snp.makeConstraints { make in
            make.top.equalTo(tabsStackView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        calendarCardView.snp.makeConstraints { make in
            make.top.equalTo(meetingsStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func setupActions() {
        newMeetingButton.addAction(UIAction { [weak self] _ in
            self?.handleNewMeetingTap()
        }, for: .touchUpInside)
        
        upcomingTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .upcoming
            self?.updateTabs()
            self?.reloadMeetings()
        }, for: .touchUpInside)

        pastTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .past
            self?.updateTabs()
            self?.reloadMeetings()
        }, for: .touchUpInside)

        scheduledTabButton.addAction(UIAction { [weak self] _ in
            self?.currentTab = .scheduled
            self?.updateTabs()
            self?.reloadMeetings()
        }, for: .touchUpInside)

        updateTabs()
    }
    
    private func handleNewMeetingTap() {
        let newMeetingVC = NewMeetingViewController()
        newMeetingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewControllerWithFade(newMeetingVC)
    }
    
    private func updateTabs() {
        upcomingTabButton.setSelected(currentTab == .upcoming)
        pastTabButton.setSelected(currentTab == .past)
        scheduledTabButton.setSelected(currentTab == .scheduled)
    }

    private func reloadMeetings() {
        meetingsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [MeetingItem]
        switch currentTab {
        case .upcoming:
            items = Self.upcomingMeetings
        case .past:
            items = Self.pastMeetings
        case .scheduled:
            items = Self.scheduledMeetings
        }

        var lastSection = ""
        for item in items {
            if item.sectionTitle != lastSection {
                lastSection = item.sectionTitle
                let sectionLabel = UILabel()
                sectionLabel.text = item.sectionTitle
                sectionLabel.font = .systemFont(ofSize: 16, weight: .bold)
                sectionLabel.textColor = AppColors.textPrimary
                meetingsStackView.addArrangedSubview(sectionLabel)
                meetingsStackView.setCustomSpacing(12, after: sectionLabel)
            }
            let row = MeetingCardRowView(item: item)
            row.onTap = { [weak self] in
                guard let self = self, !self.didNavigate else { return }
                self.didNavigate = true
                let data = MeetingDetailData(
                    titleText: item.title,
                    personText: item.person,
                    dateText: "\(item.day) \(item.monthYear.replacingOccurrences(of: "\n", with: " "))",
                    timeText: item.timeRange,
                    modeText: item.mode,
                    statusText: item.statusText,
                    statusTint: item.statusTint,
                    statusBackground: item.statusBackground
                )
                let detailVC = MeetingDetailViewController(data: data)
                detailVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewControllerWithFade(detailVC)
            }
            meetingsStackView.addArrangedSubview(row)
            meetingsStackView.setCustomSpacing(12, after: row)
        }
    }

    private static let upcomingMeetings: [MeetingItem] = [
        MeetingItem(
            sectionTitle: "Bu həftə",
            day: "23", monthYear: "May\n2025", weekday: "Sabah",
            weekdayTint: AppColors.primary, weekdayBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1),
            title: "Rəhbərlik görüşü", person: "Prof. Dr. İlqar Məmmədov",
            description: "Dissertasiya planının müzakirəsi",
            timeRange: "14:00 – 15:00", mode: "Online (Zoom)",
            statusText: "Təsdiqləndi", statusTint: AppColors.primary,
            statusBackground: UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        ),
        MeetingItem(
            sectionTitle: "Növbəti həftə",
            day: "27", monthYear: "May\n2025", weekday: "Cümə",
            weekdayTint: AppColors.orange, weekdayBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1),
            title: "Tədqiqat planı müzakirəsi", person: "Prof. Dr. Aygün Əliyeva",
            description: "Metodologiya və mənbələr",
            timeRange: "11:00 – 12:00", mode: "Online (Google Meet)",
            statusText: "Gözləyir", statusTint: AppColors.orange,
            statusBackground: UIColor(red: 1, green: 0.94, blue: 0.87, alpha: 1)
        )
    ]

    private static let pastMeetings: [MeetingItem] = [
        MeetingItem(
            sectionTitle: "Keçmiş",
            day: "15", monthYear: "May\n2025", weekday: "Tamamlandı",
            weekdayTint: AppColors.green, weekdayBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1),
            title: "İlkin müzakirə", person: "Prof. Dr. İlqar Məmmədov",
            description: "Mövzu təsdiqi",
            timeRange: "10:00 – 11:00", mode: "Online (Zoom)",
            statusText: "Tamamlandı", statusTint: AppColors.green,
            statusBackground: UIColor(red: 0.9, green: 0.97, blue: 0.93, alpha: 1)
        )
    ]

    private static let scheduledMeetings: [MeetingItem] = [
        MeetingItem(
            sectionTitle: "Planlaşdırılan",
            day: "30", monthYear: "May\n2025", weekday: "Plan",
            weekdayTint: AppColors.purple, weekdayBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1),
            title: "Hesabat təqdimatı", person: "Prof. Dr. Aygün Əliyeva",
            description: "Ara hesabat müzakirəsi",
            timeRange: "15:00 – 16:00", mode: "Online (Zoom)",
            statusText: "Planlaşdırılıb", statusTint: AppColors.purple,
            statusBackground: UIColor(red: 0.93, green: 0.9, blue: 1, alpha: 1)
        )
    ]
}

extension StudentMeetingsViewController: TabScreenHeaderViewDelegate {
    func tabScreenHeaderDidTapMenu(_ header: TabScreenHeaderView) {
        presentSideMenu(current: sideMenuItem(for: notificationsOrigin), delegate: self)
    }

    func tabScreenHeaderDidTapNotifications(_ header: TabScreenHeaderView) {
        guard !didNavigate else { return }
        didNavigate = true
        pushNotificationsScreen(from: notificationsOrigin)
    }

    private func sideMenuItem(for origin: NotificationsOrigin) -> SideMenuItem {
        switch origin {
        case .home: return .home
        case .research: return .research
        case .meetings: return .meetings
        case .messages: return .messages
        case .profile: return .profile
        }
    }
}
 
extension StudentMeetingsViewController: SideMenuViewControllerDelegate {}
private final class MeetingCardRowView: UIView {
    
    var onTap: (() -> Void)?
    
    init(item: MeetingItem) {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.shadowColor = AppColors.cardShadow
        layer.shadowOpacity = 0.04
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12

        let dateCard = UIView()
        dateCard.backgroundColor = UIColor(red: 0.9, green: 0.94, blue: 1, alpha: 1)
        dateCard.layer.cornerRadius = 14

        let dayLabel = UILabel()
        dayLabel.text = item.day
        dayLabel.font = .systemFont(ofSize: 20, weight: .bold)
        dayLabel.textColor = AppColors.primary
        dayLabel.textAlignment = .center

        let monthLabel = UILabel()
        monthLabel.text = item.monthYear
        monthLabel.font = .systemFont(ofSize: 10, weight: .medium)
        monthLabel.textColor = AppColors.primary
        monthLabel.textAlignment = .center
        monthLabel.numberOfLines = 2

        let weekdayBadge = UILabel()
        weekdayBadge.text = item.weekday
        weekdayBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        weekdayBadge.textColor = item.weekdayTint
        weekdayBadge.backgroundColor = item.weekdayBackground
        weekdayBadge.textAlignment = .center
        weekdayBadge.layer.cornerRadius = 8
        weekdayBadge.clipsToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = item.title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = AppColors.textPrimary

        let personLabel = UILabel()
        personLabel.text = item.person
        personLabel.font = .systemFont(ofSize: 13)
        personLabel.textColor = AppColors.textSecondary

        let descLabel = UILabel()
        descLabel.text = item.description
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = AppColors.textMuted

        let timeLabel = UILabel()
        timeLabel.text = "🕐 \(item.timeRange)"
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = AppColors.textMuted

        let modeLabel = UILabel()
        modeLabel.text = "📹 \(item.mode)"
        modeLabel.font = .systemFont(ofSize: 12)
        modeLabel.textColor = AppColors.textMuted

        let statusBadge = UILabel()
        statusBadge.text = item.statusText
        statusBadge.font = .systemFont(ofSize: 11, weight: .semibold)
        statusBadge.textColor = item.statusTint
        statusBadge.backgroundColor = item.statusBackground
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 10
        statusBadge.clipsToBounds = true

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColors.textMuted
        chevron.contentMode = .scaleAspectFit

        addSubview(dateCard)
        dateCard.addSubview(dayLabel)
        dateCard.addSubview(monthLabel)
        addSubview(weekdayBadge)
        addSubview(titleLabel)
        addSubview(personLabel)
        addSubview(descLabel)
        addSubview(timeLabel)
        addSubview(modeLabel)
        addSubview(statusBadge)
        addSubview(chevron)

        dateCard.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.width.equalTo(56)
            make.height.equalTo(56)
        }
        dayLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.centerX.equalToSuperview()
        }
        monthLabel.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(1)
            make.centerX.equalToSuperview()
        }
        weekdayBadge.snp.makeConstraints { make in
            make.top.equalTo(dateCard.snp.bottom).offset(8)
            make.leading.equalTo(dateCard)
            make.width.equalTo(56)
            make.height.equalTo(22)
            make.bottom.equalToSuperview().offset(-16)
        }
        statusBadge.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }
        statusBadge.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(80)
        }
        chevron.snp.makeConstraints { make in
            make.centerY.equalTo(dateCard)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(14)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateCard)
            make.leading.equalTo(dateCard.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualTo(statusBadge.snp.leading).offset(-8)
        }
        personLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
            make.leading.equalTo(titleLabel)
        }
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(personLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(chevron.snp.leading).offset(-8)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(8)
            make.leading.equalTo(titleLabel)
        }
        modeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.leading.equalTo(timeLabel.snp.trailing).offset(12)
        }
        setupTapGesture()
        
    }
    private func setupTapGesture() {
           let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
           self.addGestureRecognizer(tap)
           self.isUserInteractionEnabled = true
       }
    
    @objc private func handleTap() {
            onTap?()
        }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
