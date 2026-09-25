import UIKit

/// Displays a list of past orders and their current statuses
final class OrderStatusViewController: UIViewController {
    
    private var orders: [OrderResponse] = []
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        return tv
    }()
    
    private let emptyStateView: UIStackView = {
        let icon = UILabel()
        icon.text = "📋"
        icon.font = .systemFont(ofSize: 64)
        icon.textAlignment = .center
        
        let title = UILabel()
        title.text = "No orders yet"
        title.font = Theme.headingFont(size: 20)
        title.textColor = .label
        title.textAlignment = .center
        
        let subtitle = UILabel()
        subtitle.text = "Your order history will appear here"
        subtitle.font = Theme.bodyFont(size: 14)
        subtitle.textColor = Theme.secondaryText
        subtitle.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [icon, title, subtitle])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        return stack
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        ai.color = Theme.accentColor
        return ai
    }()
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "My Orders"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchOrders()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(activityIndicator)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OrderCell")
        
        refreshControl.tintColor = Theme.accentColor
        refreshControl.addTarget(self, action: #selector(refreshOrders), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    // MARK: - Networking
    
    private func fetchOrders() {
        if orders.isEmpty {
            activityIndicator.startAnimating()
        }
        
        Task {
            do {
                let fetchedOrders = try await APIService.shared.fetchOrders()
                DispatchQueue.main.async {
                    self.orders = fetchedOrders
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.emptyStateView.isHidden = !self.orders.isEmpty
                    self.tableView.isHidden = self.orders.isEmpty
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    // Silently fail if no connection
                    if self.orders.isEmpty {
                        self.emptyStateView.isHidden = false
                    }
                }
            }
        }
    }
    
    @objc private func refreshOrders() {
        fetchOrders()
    }
    
    // MARK: - Helpers
    
    private func statusIcon(for status: String) -> String {
        switch status {
        case "placed":          return "🟡"
        case "confirmed":       return "🟢"
        case "preparing":       return "👨‍🍳"
        case "ready":           return "✅"
        case "out_for_delivery": return "🚗"
        case "delivered":       return "🎉"
        case "cancelled":       return "❌"
        default:                return "⚪"
        }
    }
    
    private func statusColor(for status: String) -> UIColor {
        switch status {
        case "placed":          return .systemYellow
        case "confirmed":       return Theme.successColor
        case "preparing":       return Theme.accentColor
        case "ready":           return Theme.successColor
        case "out_for_delivery": return .systemBlue
        case "delivered":       return Theme.successColor
        case "cancelled":       return Theme.spicyRed
        default:                return Theme.secondaryText
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension OrderStatusViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let order = orders[indexPath.row]
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "OrderCell")
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        // Build a card-style content view
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = Theme.cardBackground
        cardView.layer.cornerRadius = Theme.smallCornerRadius
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
        ])
        
        // Order ID
        let orderIDLabel = UILabel()
        orderIDLabel.text = "Order #\(order.id.uuidString.prefix(8).uppercased())"
        orderIDLabel.font = Theme.headingFont(size: 14)
        orderIDLabel.textColor = .label
        
        // Items summary
        let itemsSummary = order.items.map { "\($0.quantity)x \($0.itemName)" }.joined(separator: ", ")
        let itemsLabel = UILabel()
        itemsLabel.text = itemsSummary
        itemsLabel.font = Theme.captionFont(size: 12)
        itemsLabel.textColor = Theme.secondaryText
        itemsLabel.numberOfLines = 2
        
        // Status badge
        let statusLabel = UILabel()
        statusLabel.text = "\(statusIcon(for: order.status)) \(order.statusDisplayName)"
        statusLabel.font = Theme.captionFont(size: 12)
        statusLabel.textColor = statusColor(for: order.status)
        
        // Total
        let totalLabel = UILabel()
        totalLabel.text = order.formattedTotal
        totalLabel.font = Theme.priceFont(size: 15)
        totalLabel.textColor = Theme.accentColor
        totalLabel.textAlignment = .right
        
        // Layout
        let leftStack = UIStackView(arrangedSubviews: [orderIDLabel, itemsLabel, statusLabel])
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        leftStack.axis = .vertical
        leftStack.spacing = 4
        
        cardView.addSubview(leftStack)
        cardView.addSubview(totalLabel)
        totalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            leftStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            leftStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            leftStack.trailingAnchor.constraint(lessThanOrEqualTo: totalLabel.leadingAnchor, constant: -12),
            
            totalLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
        ])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
