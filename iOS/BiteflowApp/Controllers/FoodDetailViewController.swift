import UIKit

/// Detailed view for a single food item with add-to-cart functionality
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
        
        // Scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        // Hero image
        contentStack.addArrangedSubview(heroImageView)
        heroImageView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        
        // Info section (padded)
        let infoContainer = UIView()
        let nameContainer = wrapInPadded(nameLabel)
        let descContainer = wrapInPadded(descriptionLabel)
        let metaContainer = wrapInPadded(metaStack)
        
        contentStack.addArrangedSubview(nameContainer)
        contentStack.addArrangedSubview(descContainer)
        contentStack.addArrangedSubview(metaContainer)
        
        // Badge row
        let badgeRow = UIStackView()
        badgeRow.axis = .horizontal
        badgeRow.spacing = 8
        
        if foodItem.isVegetarian {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "🌱", text: "Vegetarian", color: Theme.vegGreen))
        }
        if foodItem.isSpicy {
            badgeRow.addArrangedSubview(createInfoBadge(icon: "🌶️", text: "Spicy", color: Theme.spicyRed))
        }
        badgeRow.addArrangedSubview(UIView()) // spacer
        
        contentStack.addArrangedSubview(wrapInPadded(badgeRow))
        
        // Spacer at bottom for scroll clearance
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 100).isActive = true
        contentStack.addArrangedSubview(spacer)
        
        // Bottom bar
        view.addSubview(bottomBar)
        
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
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 70),
            
            stepperStack.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 20),
            stepperStack.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            
            addToCartButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -20),
            addToCartButton.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            addToCartButton.heightAnchor.constraint(equalToConstant: 46),
            addToCartButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
            
            quantityLabel.widthAnchor.constraint(equalToConstant: 32),
        ])
        
        // Actions
        minusButton.addTarget(self, action: #selector(decrementQuantity), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(incrementQuantity), for: .touchUpInside)
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
    }
    
    private func configureContent() {
        nameLabel.text = foodItem.name
        descriptionLabel.text = foodItem.description
        
        // Meta info cards
        metaStack.addArrangedSubview(createMetaCard(icon: "⭐", value: String(format: "%.1f", foodItem.rating), label: "Rating"))
        metaStack.addArrangedSubview(createMetaCard(icon: "🔥", value: "\(foodItem.calories)", label: "Calories"))
        metaStack.addArrangedSubview(createMetaCard(icon: "⏱️", value: "\(foodItem.prepTimeMinutes)m", label: "Prep Time"))
        
        updateAddButtonTitle()
        loadImage()
    }
    
    // MARK: - Actions
    
    @objc private func decrementQuantity() {
        quantity = max(1, quantity - 1)
        quantityLabel.text = "\(quantity)"
        updateAddButtonTitle()
    }
    
    @objc private func incrementQuantity() {
        quantity += 1
        quantityLabel.text = "\(quantity)"
        updateAddButtonTitle()
    }
    
    @objc private func addToCartTapped() {
        addToCartButton.addBounceAnimation()
        CartManager.shared.addItem(foodItem, quantity: quantity)
        
        // Show confirmation and pop back
        let alert = UIAlertController(
            title: "Added to Cart! 🛒",
            message: "\(quantity)x \(foodItem.name) added to your cart.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Continue Browsing", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "View Cart", style: .cancel) { [weak self] _ in
            self?.tabBarController?.selectedIndex = 1  // Switch to Cart tab
        })
        present(alert, animated: true)
    }
    
    private func updateAddButtonTitle() {
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
    
    private func loadImage() {
        guard let url = URL(string: foodItem.imageURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.heroImageView.image = image
            }
        }.resume()
    }
}
