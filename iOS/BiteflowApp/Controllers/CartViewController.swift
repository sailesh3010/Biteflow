import UIKit

/// Shopping cart view with Dine-In table ordering, bill splitting, upsell bar, and checkout
final class CartViewController: UIViewController {
    
    private let cart = CartManager.shared
    
    // MARK: - UI Elements
    
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.separatorStyle = .singleLine
        tv.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseID)
        return tv
    }()
    
    private let emptyStateView: UIView = {
        let icon = UILabel()
        icon.text = "🛒"
        icon.font = .systemFont(ofSize: 56)
        icon.textAlignment = .center
        
        let title = UILabel()
        title.text = "Your Cart is Empty"
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
    
    // Dining Mode Selector (Dine-In, Takeout, Delivery)
    private let diningSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["🍽️ Dine-In", "🛍️ Takeout", "🛵 Delivery"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = Theme.accentColor
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.label], for: .normal)
        return sc
    }()
    
    // Table & Bill Split Card (Dine-In Operations)
    private let dineInInfoCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = 10
        return v
    }()
    
    private let tableLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.headingFont(size: 14)
        label.textColor = .label
        label.text = "Table #4"
        return label
    }()
    
    private let changeTableButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Change Table", for: .normal)
        btn.titleLabel?.font = Theme.captionFont(size: 12)
        btn.setTitleColor(Theme.accentColor, for: .normal)
        return btn
    }()
    
    private let splitTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.bodyFont(size: 13)
        label.textColor = Theme.secondaryText
        label.text = "Split Bill (1 guest):"
        return label
    }()
    
    private let splitStepper: UIStepper = {
        let s = UIStepper()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.minimumValue = 1
        s.maximumValue = 8
        s.value = 1
        return s
    }()
    
    private let perPersonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.priceFont(size: 13)
        label.textColor = Theme.accentColor
        label.text = "$0.00 / person"
        return label
    }()
    
    // Complete Your Meal Upsell Strip
    private let upsellContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = 8
        return v
    }()
    
    private let upsellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = Theme.secondaryText
        label.text = "✨ COMPLETE YOUR MEAL"
        return label
    }()
    
    private let addTiramisuButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("🍰 Tiramisu (+$9.49)", for: .normal)
        btn.titleLabel?.font = Theme.captionFont(size: 12)
        btn.backgroundColor = Theme.accentColor.withAlphaComponent(0.12)
        btn.setTitleColor(Theme.accentColor, for: .normal)
        btn.layer.cornerRadius = 6
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return btn
    }()
    
    private let addEspressoButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("☕ Double Espresso (+$3.50)", for: .normal)
        btn.titleLabel?.font = Theme.captionFont(size: 12)
        btn.backgroundColor = Theme.accentColor.withAlphaComponent(0.12)
        btn.setTitleColor(Theme.accentColor, for: .normal)
        btn.layer.cornerRadius = 6
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
        return btn
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
    private let deliveryRow = PriceRowView(title: "Delivery / Service")
    private let splitRow = PriceRowView(title: "Split (per guest)")
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
    
    private var dineInCardHeightConstraint: NSLayoutConstraint?
    
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
        
        view.addSubview(diningSegmentedControl)
        view.addSubview(dineInInfoCard)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(checkoutView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Dining Info Card Setup
        dineInInfoCard.addSubview(tableLabel)
        dineInInfoCard.addSubview(changeTableButton)
        dineInInfoCard.addSubview(splitTitleLabel)
        dineInInfoCard.addSubview(splitStepper)
        dineInInfoCard.addSubview(perPersonLabel)
        
        // Upsell bar in checkout view
        upsellContainer.addSubview(upsellLabel)
        let upsellButtonsStack = UIStackView(arrangedSubviews: [addTiramisuButton, addEspressoButton])
        upsellButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        upsellButtonsStack.axis = .horizontal
        upsellButtonsStack.spacing = 8
        upsellButtonsStack.distribution = .fillProportionally
        upsellContainer.addSubview(upsellButtonsStack)
        
        // Checkout section layout
        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = Theme.separator
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let priceStack = UIStackView(arrangedSubviews: [
            subtotalRow, taxRow, deliveryRow, splitRow, divider, totalRow
        ])
        priceStack.translatesAutoresizingMaskIntoConstraints = false
        priceStack.axis = .vertical
        priceStack.spacing = 6
        
        checkoutView.addSubview(upsellContainer)
        checkoutView.addSubview(priceStack)
        checkoutView.addSubview(checkoutButton)
        
        dineInCardHeightConstraint = dineInInfoCard.heightAnchor.constraint(equalToConstant: 58)
        
        NSLayoutConstraint.activate([
            diningSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            diningSegmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            diningSegmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            diningSegmentedControl.heightAnchor.constraint(equalToConstant: 34),
            
            dineInInfoCard.topAnchor.constraint(equalTo: diningSegmentedControl.bottomAnchor, constant: 8),
            dineInInfoCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dineInInfoCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dineInCardHeightConstraint!,
            
            tableLabel.leadingAnchor.constraint(equalTo: dineInInfoCard.leadingAnchor, constant: 12),
            tableLabel.topAnchor.constraint(equalTo: dineInInfoCard.topAnchor, constant: 8),
            
            changeTableButton.leadingAnchor.constraint(equalTo: tableLabel.trailingAnchor, constant: 8),
            changeTableButton.centerYAnchor.constraint(equalTo: tableLabel.centerYAnchor),
            
            splitStepper.trailingAnchor.constraint(equalTo: dineInInfoCard.trailingAnchor, constant: -12),
            splitStepper.centerYAnchor.constraint(equalTo: dineInInfoCard.centerYAnchor),
            
            splitTitleLabel.leadingAnchor.constraint(equalTo: dineInInfoCard.leadingAnchor, constant: 12),
            splitTitleLabel.topAnchor.constraint(equalTo: tableLabel.bottomAnchor, constant: 4),
            
            perPersonLabel.leadingAnchor.constraint(equalTo: splitTitleLabel.trailingAnchor, constant: 6),
            perPersonLabel.centerYAnchor.constraint(equalTo: splitTitleLabel.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: dineInInfoCard.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: checkoutView.topAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            
            checkoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            checkoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            checkoutView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            upsellContainer.topAnchor.constraint(equalTo: checkoutView.topAnchor, constant: 12),
            upsellContainer.leadingAnchor.constraint(equalTo: checkoutView.leadingAnchor, constant: 16),
            upsellContainer.trailingAnchor.constraint(equalTo: checkoutView.trailingAnchor, constant: -16),
            upsellContainer.heightAnchor.constraint(equalToConstant: 62),
            
            upsellLabel.topAnchor.constraint(equalTo: upsellContainer.topAnchor, constant: 6),
            upsellLabel.leadingAnchor.constraint(equalTo: upsellContainer.leadingAnchor, constant: 10),
            
            upsellButtonsStack.topAnchor.constraint(equalTo: upsellLabel.bottomAnchor, constant: 4),
            upsellButtonsStack.leadingAnchor.constraint(equalTo: upsellContainer.leadingAnchor, constant: 10),
            upsellButtonsStack.trailingAnchor.constraint(equalTo: upsellContainer.trailingAnchor, constant: -10),
            upsellButtonsStack.heightAnchor.constraint(equalToConstant: 28),
            
            priceStack.topAnchor.constraint(equalTo: upsellContainer.bottomAnchor, constant: 12),
            priceStack.leadingAnchor.constraint(equalTo: checkoutView.leadingAnchor, constant: 20),
            priceStack.trailingAnchor.constraint(equalTo: checkoutView.trailingAnchor, constant: -20),
            
            checkoutButton.topAnchor.constraint(equalTo: priceStack.bottomAnchor, constant: 12),
            checkoutButton.leadingAnchor.constraint(equalTo: checkoutView.leadingAnchor, constant: 20),
            checkoutButton.trailingAnchor.constraint(equalTo: checkoutView.trailingAnchor, constant: -20),
            checkoutButton.heightAnchor.constraint(equalToConstant: 48),
            checkoutButton.bottomAnchor.constraint(equalTo: checkoutView.bottomAnchor, constant: -10),
        ])
        
        diningSegmentedControl.addTarget(self, action: #selector(diningModeChanged), for: .valueChanged)
        changeTableButton.addTarget(self, action: #selector(changeTableTapped), for: .touchUpInside)
        splitStepper.addTarget(self, action: #selector(splitStepperChanged), for: .valueChanged)
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        
        addTiramisuButton.addTarget(self, action: #selector(addTiramisuUpsell), for: .touchUpInside)
        addEspressoButton.addTarget(self, action: #selector(addEspressoUpsell), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func diningModeChanged() {
        switch diningSegmentedControl.selectedSegmentIndex {
        case 0:
            cart.selectedDiningOption = .dineIn
            dineInInfoCard.isHidden = false
            dineInCardHeightConstraint?.constant = 58
            splitRow.isHidden = false
        case 1:
            cart.selectedDiningOption = .pickup
            dineInInfoCard.isHidden = true
            dineInCardHeightConstraint?.constant = 0
            splitRow.isHidden = true
        default:
            cart.selectedDiningOption = .delivery
            dineInInfoCard.isHidden = true
            dineInCardHeightConstraint?.constant = 0
            splitRow.isHidden = true
        }
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        refreshUI()
    }
    
    @objc private func changeTableTapped() {
        let alert = UIAlertController(title: "Select Table", message: "Enter your Bistro Table Number", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = self.cart.tableNumber
            tf.placeholder = "e.g. Table 12 or Patio 3"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self, let text = alert.textFields?.first?.text, !text.isEmpty else { return }
            self.cart.tableNumber = text
            self.tableLabel.text = text
            self.refreshUI()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func splitStepperChanged() {
        let count = Int(splitStepper.value)
        cart.splitCount = count
        splitTitleLabel.text = "Split Bill (\(count) \(count == 1 ? "guest" : "guests")):"
        refreshUI()
    }
    
    @objc private func addTiramisuUpsell() {
        addTiramisuButton.addBounceAnimation()
        cart.addPairing(name: "Tiramisu Tradizionale", price: 9.49)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    @objc private func addEspressoUpsell() {
        addEspressoButton.addBounceAnimation()
        cart.addPairing(name: "Double Espresso", price: 3.50)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    // MARK: - Refresh
    
    private func refreshUI() {
        tableView.reloadData()
        
        let isEmpty = cart.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        checkoutView.isHidden = isEmpty
        diningSegmentedControl.isHidden = isEmpty
        dineInInfoCard.isHidden = isEmpty || (cart.selectedDiningOption != .dineIn)
        
        subtotalRow.setValue(cart.formattedSubtotal)
        taxRow.setValue(cart.formattedTax)
        deliveryRow.setValue(cart.formattedDeliveryFee)
        totalRow.setValue(cart.formattedTotal)
        
        perPersonLabel.text = cart.formattedPerPersonSplit
        splitRow.setValue(cart.formattedPerPersonSplit)
        splitRow.isHidden = cart.selectedDiningOption != .dineIn || cart.splitCount <= 1
        
        tableLabel.text = cart.tableNumber
        
        let optionTitle = cart.selectedDiningOption.title
        checkoutButton.setTitle("Place Order — \(optionTitle) (\(cart.formattedTotal))", for: .normal)
    }
    
    @objc private func cartDidChange() {
        refreshUI()
    }
    
    // MARK: - Checkout
    
    @objc private func checkoutTapped() {
        let option = cart.selectedDiningOption
        let title = "Confirm \(option.title)"
        let message: String
        
        switch option {
        case .dineIn:
            message = "\(cart.tableNumber) · Split between \(cart.splitCount) \(cart.splitCount == 1 ? "guest" : "guests") (\(cart.formattedPerPersonSplit))"
        case .pickup:
            message = "Pick up at main Bistro counter in 15–20 minutes"
        case .delivery:
            message = "Enter delivery address for courier delivery"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "Your Name (e.g. Sarah J.)" }
        alert.addTextField { tf in tf.placeholder = "Phone Number"; tf.keyboardType = .phonePad }
        
        if option == .delivery {
            alert.addTextField { tf in tf.placeholder = "Delivery Address" }
        }
        
        alert.addAction(UIAlertAction(title: "Confirm Order", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let name = alert.textFields?[0].text ?? "Guest"
            let phone = alert.textFields?[1].text ?? "555-0100"
            let address = option == .delivery ? (alert.textFields?[2].text ?? "123 Main St") : option.rawValue
            
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
        let splitNote = order.splitCount > 1 ? "\nSplit (\(order.splitCount)x): \(order.formattedPerPersonSplit)" : ""
        let alert = UIAlertController(
            title: "Order Placed! 🎉",
            message: "Order #\(order.id.uuidString.prefix(8))\n\(order.diningOptionDisplay)\nTotal: \(order.formattedTotal)\(splitNote)\n\nTrack kitchen progress in the Orders tab.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Track Order", style: .default) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 2
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CartItemCell.reuseID, for: indexPath
        ) as? CartItemCell else { return UITableViewCell() }
        
        let item = cart.items[indexPath.row]
        cell.configure(with: item)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
}

// MARK: - CartItemCellDelegate

extension CartViewController: CartItemCellDelegate {
    func cartItemCellDidUpdateQuantity(_ cell: CartItemCell, item: CartItem, newQuantity: Int) {
        cart.updateQuantity(for: item.foodItem, quantity: newQuantity)
    }
    
    func cartItemCellDidRemove(_ cell: CartItemCell, item: CartItem) {
        cart.removeItem(item.foodItem)
    }
}
