import UIKit

/// Detailed view for a single food item with 86'd status, pairing upsell, and add-to-cart functionality
final class FoodDetailViewController: UIViewController {
    
    private let foodItem: FoodItemResponse
    private var quantity: Int = 1
    
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
        sv.spacing = 16
        return sv
    }()
    
    private let heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.titleFont(size: 26)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = Theme.bodyFont(size: 15)
        label.textColor = Theme.secondaryText
        label.numberOfLines = 0
        return label
    }()
    
    private let metaStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        sv.distribution = .fillEqually
        return sv
    }()
    
    // Chef's Pairing Card (AOV Upsell Feature)
    private let pairingCard: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        v.layer.borderWidth = 1
        v.layer.borderColor = Theme.accentColor.withAlphaComponent(0.3).cgColor
        return v
    }()
    
    // Bottom bar
    private let bottomBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        return v
    }()
    
    private let minusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "minus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28)), for: .normal)
        btn.tintColor = Theme.secondaryText
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.headingFont(size: 20)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    
    private let plusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 28)), for: .normal)
        btn.tintColor = Theme.accentColor
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let addToCartButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = Theme.accentColor
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = Theme.headingFont(size: 16)
        btn.layer.cornerRadius = Theme.smallCornerRadius
        return btn
    }()
    
    // MARK: - Init
    
    init(foodItem: FoodItemResponse) {
        self.foodItem = foodItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubview(heroImageView)
        heroImageView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        let nameContainer = wrapInPadded(nameLabel)
        let descContainer = wrapInPadded(descriptionLabel)
        let metaContainer = wrapInPadded(metaStack)
        
        contentStack.addArrangedSubview(nameContainer)
        contentStack.addArrangedSubview(descContainer)
        contentStack.addArrangedSubview(metaContainer)
        
        // Dietary Badges & Low Stock Row
        let badgeRow = UIStackView()
        badgeRow.axis = .horizontal
        badgeRow.spacing = 8
        
        if !foodItem.isAvailable {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "⛔", text: "86'd (Sold Out)", color: .systemRed))
        } else if let lowStockText = foodItem.lowStockDisplay {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "🔥", text: lowStockText, color: .systemOrange))
        }
        
        if foodItem.isVegetarian {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "🌱", text: "Vegetarian", color: Theme.vegGreen))
        }
        if foodItem.isSpicy {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "🌶️", text: "Spicy", color: Theme.spicyRed))
        }
        badgeRow.addArrangedSubview(UIView())
        contentStack.addArrangedSubview(wrapInPadded(badgeRow))
        
        // Chef's Signature Pairing Card (Upsell Engine)
        if let pairingName = foodItem.pairingName, let pairingPrice = foodItem.pairingPrice {
            setupPairingCard(name: pairingName, price: pairingPrice)
            contentStack.addArrangedSubview(wrapInPadded(pairingCard))
        }
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        // Bottom bar
        view.addSubview(bottomBar)
        Theme.applyCardShadow(to: bottomBar.layer)
        
        let stepperStack = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton])
        stepperStack.translatesAutoresizingMaskIntoConstraints = false
        stepperStack.axis = .horizontal
        stepperStack.spacing = 12
        stepperStack.alignment = .center
        
        bottomBar.addSubview(stepperStack)
        bottomBar.addSubview(addToCartButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70),
            
            stepperStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            stepperStack.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 14),
            
            addToCartButton.leadingAnchor.constraint(equalTo: stepperStack.trailingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            addToCartButton.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 10),
            addToCartButton.heightAnchor.constraint(equalToConstant: 48),
        ])
        
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    
    private func setupPairingCard(name: String, price: Double) {
        let iconLabel = UILabel()
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconLabel.text = "🍷"
        iconLabel.font = .systemFont(ofSize: 24)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Chef's Recommended Pairing"
        titleLabel.font = Theme.headingFont(size: 14)
        titleLabel.textColor = Theme.accentColor
        
        let itemNameLabel = UILabel()
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        itemNameLabel.text = "\(name) — $\(String(format: "%.2f", price))"
        itemNameLabel.font = Theme.bodyFont(size: 13)
        itemNameLabel.textColor = .label
        
        let addPairingBtn = UIButton(type: .system)
        addPairingBtn.translatesAutoresizingMaskIntoConstraints = false
        addPairingBtn.setTitle("+ Add Pairing", for: .normal)
        addPairingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        addPairingBtn.backgroundColor = Theme.accentColor.withAlphaComponent(0.12)
        addPairingBtn.setTitleColor(Theme.accentColor, for: .normal)
        addPairingBtn.layer.cornerRadius = 8
        addPairingBtn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        
        addPairingBtn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            addPairingBtn.addBounceAnimation()
            CartManager.shared.addPairing(name: name, price: price)
            
            let feedback = UINotificationFeedbackGenerator()
            feedback.notificationOccurred(.success)
            
            let toast = UIAlertController(title: "Pairing Added! 🍷", message: "\(name) added to your order.", preferredStyle: .alert)
            self.present(toast, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                toast.dismiss(animated: true)
            }
        }, for: .touchUpInside)
        
        let labelStack = UIStackView(arrangedSubviews: [titleLabel, itemNameLabel])
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        labelStack.axis = .vertical
        labelStack.spacing = 3
        
        pairingCard.addSubview(iconLabel)
        pairingCard.addSubview(labelStack)
        pairingCard.addSubview(addPairingBtn)
        
        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: pairingCard.leadingAnchor, constant: 14),
            iconLabel.centerYAnchor.constraint(equalTo: pairingCard.centerYAnchor),
            
            labelStack.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 12),
            labelStack.centerYAnchor.constraint(equalTo: pairingCard.centerYAnchor),
            labelStack.trailingAnchor.constraint(lessThanOrEqualTo: addPairingBtn.leadingAnchor, constant: -8),
            
            addPairingBtn.trailingAnchor.constraint(equalTo: pairingCard.trailingAnchor, constant: -14),
            addPairingBtn.centerYAnchor.constraint(equalTo: pairingCard.centerYAnchor),
            
            pairingCard.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    // MARK: - Content
    
    private func configureContent() {
        nameLabel.text = foodItem.name
        descriptionLabel.text = foodItem.description
        
        // Meta cards
        metaStack.addArrangedSubview(createMetaCard(icon: "⭐", value: String(format: "%.1f", foodItem.rating), label: "Rating"))
        metaStack.addArrangedSubview(createMetaCard(icon: "🔥", value: "\(foodItem.calories)", label: "Calories"))
        metaStack.addArrangedSubview(createMetaCard(icon: "⏱️", value: foodItem.prepTimeDisplay, label: "Prep Time"))
        
        updateAddButtonTitle()
        
        // Handle 86'd status
        if !foodItem.isAvailable {
            addToCartButton.isEnabled = false
            addToCartButton.backgroundColor = .systemGray4
            addToCartButton.setTitle("Sold Out for Today (86'd)", for: .normal)
            minusButton.isEnabled = false
            plusButton.isEnabled = false
        }
        
        // Load image
        if let url = URL(string: foodItem.imageURL) {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.heroImageView.image = img
                }
            }.resume()
        }
    }
    
    // MARK: - Actions
    
    @objc private func minusTapped() {
        guard quantity > 1 else { return }
        quantity -= 1
        quantityLabel.text = "\(quantity)"
        updateAddButtonTitle()
        minusButton.addBounceAnimation()
    }
    
    @objc private func plusTapped() {
        quantity += 1
        quantityLabel.text = "\(quantity)"
        updateAddButtonTitle()
        plusButton.addBounceAnimation()
    }
    
    @objc private func addToCartTapped() {
        guard foodItem.isAvailable else { return }
        addToCartButton.addBounceAnimation()
        CartManager.shared.addItem(foodItem, quantity: quantity)
        
        let alert = UIAlertController(
            title: "Added to Cart! 🛒",
            message: "\(quantity)x \(foodItem.name) added to your cart.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue Browsing", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "View Cart", style: .cancel) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 1
        })
        present(alert, animated: true)
    }
    
    private func updateAddButtonTitle() {
        guard foodItem.isAvailable else { return }
        let totalPrice = foodItem.price * Double(quantity)
        addToCartButton.setTitle("Add to Cart — \(String(format: "$%.2f", totalPrice))", for: .normal)
    }
    
    // MARK: - Helpers
    
    private func wrapInPadded(_ view: UIView) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
        ])
        return container
    }
    
    private func createMetaCard(icon: String, value: String, label: String) -> UIView {
        let card = UIView()
        card.backgroundColor = Theme.cardBackground
        card.layer.cornerRadius = Theme.smallCornerRadius
        
        let iconLbl = UILabel()
        iconLbl.text = icon
        iconLbl.font = .systemFont(ofSize: 20)
        iconLbl.textAlignment = .center
        
        let valueLbl = UILabel()
        valueLbl.text = value
        valueLbl.font = Theme.headingFont(size: 16)
        valueLbl.textColor = .label
        valueLbl.textAlignment = .center
        
        let labelLbl = UILabel()
        labelLbl.text = label
        labelLbl.font = Theme.captionFont(size: 11)
        labelLbl.textColor = Theme.secondaryText
        labelLbl.textAlignment = .center
        
        let stack = UIStackView(arrangedSubviews: [iconLbl, valueLbl, labelLbl])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -8),
        ])
        
        return card
    }
    
    private func createInfoBadge(icon: String, text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = "\(icon) \(text)"
        label.font = Theme.captionFont(size: 12)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.12)
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        
        let container = UIView()
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 28),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
        ])
        
        return container
    }
}
