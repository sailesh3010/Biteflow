import UIKit

/// Shopping cart screen with item list, pricing breakdown, and checkout
final class CartViewController: UIViewController {
    
    private let cart = CartManager.shared
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .none
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseID)
        return tv
    }()
    
    private let emptyStateView: UIStackView = {
        let icon = UILabel()
        icon.text = "🛒"
        icon.font = .systemFont(ofSize: 64)
        icon.textAlignment = .center
        
        let title = UILabel()
        title.text = "Your cart is empty"
        title.font = Theme.headingFont(size: 20)
        title.textColor = .label
        title.textAlignment = .center
        
        let subtitle = UILabel()
        subtitle.text = "Add some delicious items from the menu!"
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
    
    // Bottom checkout section
    private let checkoutView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v
    }()
    
    private let subtotalRow = PriceRowView(title: "Subtotal")
    private let taxRow = PriceRowView(title: "Tax (8%)")
    private let deliveryRow = PriceRowView(title: "Delivery")
    private let totalRow = PriceRowView(title: "Total", isBold: true)
    
    private let checkoutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Place Order", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = Theme.headingFont(size: 17)
        btn.backgroundColor = Theme.accentColor
        btn.layer.cornerRadius = Theme.smallCornerRadius
        return btn
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        setupUI()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(cartDidChange),
            name: CartManager.cartDidChangeNotification, object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(checkoutView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Checkout section layout
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Theme.separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let priceStack = UIStackView(arrangedSubviews: [
            subtotalRow, taxRow, deliveryRow, divider, totalRow
        ])
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.axis = .vertical
        priceStack.spacing = 8
        
        checkoutView.addSubview(priceStack)
        checkoutView.addSubview(checkoutButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: checkoutView.topAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            
            checkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            checkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            checkoutView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            priceStack.topAnchor.constraint(equalTo: checkoutView.topAnchor, constant: 16),
            priceStack.leadingAnchor.constraint(equalTo: checkoutView.leadingAnchor, constant: 20),
            priceStack.trailingAnchor.constraint(equalTo: checkoutView.trailingAnchor, constant: -20),
            
            checkoutButton.topAnchor.constraint(equalTo: priceStack.bottomAnchor, constant: 14),
            checkoutButton.leadingAnchor.constraint(equalTo: checkoutView.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: checkoutView.trailingAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),
            checkoutButton.bottomAnchor.constraint(equalTo: checkoutView.bottomAnchor, constant: -12),
        ])
        
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
    }
    
    // MARK: - Refresh
    
    private func refreshUI() {
        tableView.reloadData()
        
        let isEmpty = cart.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        checkoutView.isHidden = isEmpty
        
        subtotalRow.setValue(cart.formattedSubtotal)
        taxRow.setValue(cart.formattedTax)
        deliveryRow.setValue(cart.formattedDeliveryFee)
        totalRow.setValue(cart.formattedTotal)
    }
    
    @objc private func cartDidChange() {
        refreshUI()
    }
    
    // MARK: - Checkout
    
    @objc private func checkoutTapped() {
        let alert = UIAlertController(
            title: "Checkout",
            message: "Enter your delivery details",
            preferredStyle: .alert
        )
        
        alert.addTextField { tf in tf.placeholder = "Your Name" }
        alert.addTextField { tf in tf.placeholder = "Phone Number"; tf.keyboardType = .phonePad }
        alert.addTextField { tf in tf.placeholder = "Delivery Address" }
        
        alert.addAction(UIAlertAction(title: "Place Order", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?[0].text ?? "Guest"
            let phone = alert.textFields?[1].text ?? ""
            let address = alert.textFields?[2].text ?? ""
            
            self.placeOrder(name: name, phone: phone, address: address)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func placeOrder(name: String, phone: String, address: String) {
        let request = cart.buildOrderRequest(
            customerName: name,
            customerPhone: phone,
            deliveryAddress: address
        )
        
        Task {
            do {
                let order = try await APIService.shared.placeOrder(request: request)
                DispatchQueue.main.async {
                    self.cart.clearCart()
                    self.showOrderConfirmation(order: order)
                }
            } catch {
                DispatchQueue.main.async {
                    let alert = UIAlertController(
                        title: "Order Failed",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func showOrderConfirmation(order: OrderResponse) {
        let alert = UIAlertController(
            title: "Order Placed! 🎉",
            message: "Order #\(order.id.uuidString.prefix(8))\nTotal: \(order.formattedTotal)\n\nTrack your order in the Orders tab.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Track Order", style: .default) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2  // Switch to Orders tab
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & Delegate

extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseID, for: indexPath) as! CartItemCell
        let cartItem = cart.items[indexPath.row]
        cell.configure(with: cartItem)
        
        cell.onQuantityChanged = { [weak self] newQuantity in
            self?.cart.updateQuantity(for: cartItem.foodItem, quantity: newQuantity)
        }
        
        cell.onRemove = { [weak self] in
            self?.cart.removeItem(cartItem.foodItem)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Price Row Helper View

final class PriceRowView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.bodyFont(size: 14)
        label.textColor = Theme.secondaryText
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.bodyFont(size: 14)
        label.textColor = .label
        label.textAlignment = .right
        return label
    }()
    
    init(title: String, isBold: Bool = false) {
        super.init(frame: .zero)
        titleLabel.text = title
        if isBold {
            titleLabel.font = Theme.headingFont(size: 16)
            titleLabel.textColor = .label
            valueLabel.font = Theme.priceFont(size: 18)
            valueLabel.textColor = Theme.accentColor
        }
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setValue(_ text: String) {
        valueLabel.text = text
    }
}
