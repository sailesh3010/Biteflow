import UIKit

/// Manager Portal view controller: Live Shift Analytics, Z-Report, Rush Mode Throttle, and 86'd Item Manager
final class BistroPortalViewController: UIViewController {
    
    // MARK: - Data
    
    private var zReport: ZReportResponse?
    private var allItems: [FoodItemResponse] = []
    private var isRushHour: Bool = false
    
    // MARK: - UI Elements
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()
    
    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 20
        return sv
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // Header Banner
    private let headerCard: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        return v
    }()
    
    // Operations Card (Rush Hour Toggle)
    private let operationsCard: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        v.layer.borderWidth = 1
        v.layer.borderColor = Theme.accentColor.withAlphaComponent(0.2).cgColor
        return v
    }()
    
    private let rushSwitch: UISwitch = {
        let s = UISwitch()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.onTintColor = .systemOrange
        return s
    }()
    
    // KPI Cards Grid
    private let kpiStackRow1 = UIStackView()
    private let kpiStackRow2 = UIStackView()
    
    private let grossSalesCard = KPICardView(title: "Gross Sales", icon: "💰")
    private let ordersCountCard = KPICardView(title: "Total Tickets", icon: "🧾")
    private let avgTicketCard = KPICardView(title: "Avg Ticket", icon: "📊")
    private let activeKitchenCard = KPICardView(title: "Kitchen Queue", icon: "🍳")
    
    // Top Dishes Card
    private let topDishesCard: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        return v
    }()
    
    private let topDishesStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()
    
    // 86'd Menu Items Quick Manager
    private let eightySixCard: UIView = {
        let v = UIView()
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        return v
    }()
    
    private let eightySixStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Manager Portal"
        setupNavigation()
        setupUI()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshTapped)
        )
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshTapped), for: .valueChanged)
        
        // Setup Header Card
        setupHeaderCard()
        contentStack.addArrangedSubview(wrapInPadded(headerCard))
        
        // Setup Rush Throttle Controls
        setupOperationsCard()
        contentStack.addArrangedSubview(wrapInPadded(operationsCard))
        
        // Setup KPI 2x2 Grid
        kpiStackRow1.axis = .horizontal
        kpiStackRow1.spacing = 12
        kpiStackRow1.distribution = .fillEqually
        kpiStackRow1.addArrangedSubview(grossSalesCard)
        kpiStackRow1.addArrangedSubview(ordersCountCard)
        
        kpiStackRow2.axis = .horizontal
        kpiStackRow2.spacing = 12
        kpiStackRow2.distribution = .fillEqually
        kpiStackRow2.addArrangedSubview(avgTicketCard)
        kpiStackRow2.addArrangedSubview(activeKitchenCard)
        
        let kpiContainer = UIStackView(arrangedSubviews: [kpiStackRow1, kpiStackRow2])
        kpiContainer.axis = .vertical
        kpiContainer.spacing = 12
        contentStack.addArrangedSubview(wrapInPadded(kpiContainer))
        
        // Setup Top Dishes
        setupTopDishesCard()
        contentStack.addArrangedSubview(wrapInPadded(topDishesCard))
        
        // Setup 86 Quick Manager
        setupEightySixCard()
        contentStack.addArrangedSubview(wrapInPadded(eightySixCard))
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 40).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }
    
    private func setupHeaderCard() {
        let badge = UILabel()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.text = "● LIVE SHIFT REPORT"
        badge.font = UIFont.systemFont(ofSize: 11, weight: .black)
        badge.textColor = Theme.vegGreen
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Daily Z-Report & Operations"
        titleLabel.font = Theme.headingFont(size: 18)
        titleLabel.textColor = .label
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        subtitleLabel.text = "Synced: \(formatter.string(from: Date()))"
        subtitleLabel.font = Theme.captionFont(size: 12)
        subtitleLabel.textColor = Theme.secondaryText
        
        headerCard.addSubview(badge)
        headerCard.addSubview(titleLabel)
        headerCard.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            badge.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 14),
            badge.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            
            titleLabel.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -14)
        ])
    }
    
    private func setupOperationsCard() {
        let icon = UILabel()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.text = "⏱️"
        icon.font = .systemFont(ofSize: 22)
        
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Kitchen Rush Hour Throttle"
        title.font = Theme.headingFont(size: 15)
        title.textColor = .label
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Adds +15m to customer prep times and alerts guests"
        subtitle.font = Theme.captionFont(size: 11)
        subtitle.textColor = Theme.secondaryText
        subtitle.numberOfLines = 2
        
        rushSwitch.addTarget(self, action: #selector(rushSwitchToggled), for: .valueChanged)
        
        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        
        operationsCard.addSubview(icon)
        operationsCard.addSubview(textStack)
        operationsCard.addSubview(rushSwitch)
        
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: operationsCard.leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: operationsCard.centerYAnchor),
            
            textStack.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: operationsCard.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: rushSwitch.leadingAnchor, constant: -8),
            
            rushSwitch.trailingAnchor.constraint(equalTo: operationsCard.trailingAnchor, constant: -14),
            rushSwitch.centerYAnchor.constraint(equalTo: operationsCard.centerYAnchor),
            
            operationsCard.heightAnchor.constraint(equalToConstant: 68)
        ])
    }
    
    private func setupTopDishesCard() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "🏆 Top Best-Selling Dishes Today"
        titleLabel.font = Theme.headingFont(size: 16)
        titleLabel.textColor = .label
        
        topDishesCard.addSubview(titleLabel)
        topDishesCard.addSubview(topDishesStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topDishesCard.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: topDishesCard.leadingAnchor, constant: 16),
            
            topDishesStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            topDishesStack.leadingAnchor.constraint(equalTo: topDishesCard.leadingAnchor, constant: 16),
            topDishesStack.trailingAnchor.constraint(equalTo: topDishesCard.trailingAnchor, constant: -16),
            topDishesStack.bottomAnchor.constraint(equalTo: topDishesCard.bottomAnchor, constant: -14)
        ])
    }
    
    private func setupEightySixCard() {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "⚡ Real-Time 86'd Menu Item Toggles"
        titleLabel.font = Theme.headingFont(size: 16)
        titleLabel.textColor = .label
        
        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Flick switch to 86 an item out of stock across all customer apps"
        subtitle.font = Theme.captionFont(size: 11)
        subtitle.textColor = Theme.secondaryText
        
        eightySixCard.addSubview(titleLabel)
        eightySixCard.addSubview(subtitle)
        eightySixCard.addSubview(eightySixStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: eightySixCard.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: eightySixCard.leadingAnchor, constant: 16),
            
            subtitle.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitle.leadingAnchor.constraint(equalTo: eightySixCard.leadingAnchor, constant: 16),
            
            eightySixStack.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 14),
            eightySixStack.leadingAnchor.constraint(equalTo: eightySixCard.leadingAnchor, constant: 16),
            eightySixStack.trailingAnchor.constraint(equalTo: eightySixCard.trailingAnchor, constant: -16),
            eightySixStack.bottomAnchor.constraint(equalTo: eightySixCard.bottomAnchor, constant: -14)
        ])
    }
    
    // MARK: - Networking
    
    private func loadData() {
        Task {
            do {
                async let reportTask = APIService.shared.fetchZReport()
                async let itemsTask = APIService.shared.fetchAllItems()
                async let statusTask = APIService.shared.fetchBistroStatus()
                
                let (report, items, status) = try await (reportTask, itemsTask, statusTask)
                
                self.zReport = report
                self.allItems = items
                self.isRushHour = status.isRushHour
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.rushSwitch.isOn = status.isRushHour
                    self.updateKPICards(report: report)
                    self.updateTopDishes(report: report)
                    self.updateEightySixList(items: items)
                }
            } catch {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @objc private func refreshTapped() {
        loadData()
    }
    
    @objc private func rushSwitchToggled() {
        let enable = rushSwitch.isOn
        Task {
            do {
                let status = try await APIService.shared.toggleRushMode(enabled: enable)
                DispatchQueue.main.async {
                    self.isRushHour = status.isRushHour
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } catch {
                DispatchQueue.main.async {
                    self.rushSwitch.isOn = !enable
                }
            }
        }
    }
    
    private func updateKPICards(report: ZReportResponse) {
        grossSalesCard.setValue(report.formattedGrossSales, subtitle: "Net: \(report.formattedNetSales)")
        ordersCountCard.setValue("\(report.totalOrders)", subtitle: "\(report.dineInOrdersCount) Dine-In · \(report.pickupOrdersCount) Takeout")
        avgTicketCard.setValue(report.formattedAvgTicket, subtitle: "Tax: \(report.formattedTaxCollected)")
        activeKitchenCard.setValue("\(report.activeKitchenTickets)", subtitle: "Tickets in prep")
    }
    
    private func updateTopDishes(report: ZReportResponse) {
        topDishesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if report.topSellingDishes.isEmpty {
            let emptyLabel = UILabel()
            emptyLabel.text = "No orders recorded yet today."
            emptyLabel.font = Theme.bodyFont(size: 13)
            emptyLabel.textColor = Theme.secondaryText
            topDishesStack.addArrangedSubview(emptyLabel)
            return
        }
        
        for (index, dish) in report.topSellingDishes.enumerated() {
            let row = makeDishRankRow(rank: index + 1, name: dish.name, quantity: dish.quantitySold, revenue: dish.formattedRevenue)
            topDishesStack.addArrangedSubview(row)
        }
    }
    
    private func updateEightySixList(items: [FoodItemResponse]) {
        eightySixStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for item in items.prefix(8) { // Show top 8 items for fast toggling
            let row = makeEightySixRow(item: item)
            eightySixStack.addArrangedSubview(row)
        }
    }
    
    private func makeDishRankRow(rank: Int, name: String, quantity: Int, revenue: String) -> UIView {
        let row = UIView()
        
        let rankBadge = UILabel()
        rankBadge.translatesAutoresizingMaskIntoConstraints = false
        rankBadge.text = "#\(rank)"
        rankBadge.font = Theme.headingFont(size: 13)
        rankBadge.textColor = Theme.accentColor
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = name
        nameLabel.font = Theme.bodyFont(size: 13)
        nameLabel.textColor = .label
        
        let salesLabel = UILabel()
        salesLabel.translatesAutoresizingMaskIntoConstraints = false
        salesLabel.text = "\(quantity) sold · \(revenue)"
        salesLabel.font = Theme.captionFont(size: 12)
        salesLabel.textColor = Theme.secondaryText
        salesLabel.textAlignment = .right
        
        row.addSubview(rankBadge)
        row.addSubview(nameLabel)
        row.addSubview(salesLabel)
        
        NSLayoutConstraint.activate([
            rankBadge.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            rankBadge.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            rankBadge.widthAnchor.constraint(equalToConstant: 24),
            
            nameLabel.leadingAnchor.constraint(equalTo: rankBadge.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: salesLabel.leadingAnchor, constant: -8),
            
            salesLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            salesLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 26)
        ])
        
        return row
    }
    
    private func makeEightySixRow(item: FoodItemResponse) -> UIView {
        let row = UIView()
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = item.name
        nameLabel.font = Theme.bodyFont(size: 13)
        nameLabel.textColor = item.isAvailable ? .label : Theme.secondaryText
        
        let statusSwitch = UISwitch()
        statusSwitch.translatesAutoresizingMaskIntoConstraints = false
        statusSwitch.isOn = item.isAvailable
        statusSwitch.onTintColor = Theme.vegGreen
        
        statusSwitch.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            let isAvailable = statusSwitch.isOn
            Task {
                _ = try? await APIService.shared.toggleItem86(id: item.id, isAvailable: isAvailable)
                DispatchQueue.main.async {
                    nameLabel.textColor = isAvailable ? .label : Theme.secondaryText
                    let gen = UIImpactFeedbackGenerator(style: .light)
                    gen.impactOccurred()
                }
            }
        }, for: .valueChanged)
        
        row.addSubview(nameLabel)
        row.addSubview(statusSwitch)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusSwitch.leadingAnchor, constant: -8),
            
            statusSwitch.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            statusSwitch.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 34)
        ])
        
        return row
    }
    
    private func wrapInPadded(_ view: UIView) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        ])
        return container
    }
}

// MARK: - KPI Card Component

final class KPICardView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 11)
        label.textColor = Theme.secondaryText
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.titleFont(size: 20)
        label.textColor = .label
        label.text = "—"
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 10)
        label.textColor = Theme.secondaryText
        return label
    }()
    
    init(title: String, icon: String) {
        super.init(frame: .zero)
        backgroundColor = Theme.cardBackground
        layer.cornerRadius = Theme.smallCornerRadius
        Theme.applyCardShadow(to: layer)
        
        titleLabel.text = "\(icon) \(title)"
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            subtitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            subtitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ value: String, subtitle: String) {
        valueLabel.text = value
        subtitleLabel.text = subtitle
    }
}
