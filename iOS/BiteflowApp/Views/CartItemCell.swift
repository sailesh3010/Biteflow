import UIKit

/// Cart table view cell with quantity stepper and item details
final class CartItemCell: UITableViewCell {
    
    static let reuseID = "CartItemCell"
    
    var onQuantityChanged: ((Int) -> Void)?
    var onRemove: (() -> Void)?
    
    private var currentQuantity: Int = 1
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.smallCornerRadius
        return v
    }()
    
    private let itemNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.headingFont(size: 15)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.priceFont(size: 15)
        label.textColor = Theme.accentColor
        return label
    }()
    
    private let subtotalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 12)
        label.textColor = Theme.secondaryText
        return label
    }()
    
    // Stepper controls
    private let minusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        btn.tintColor = Theme.secondaryText
        return btn
    }()
    
    private let quantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.headingFont(size: 16)
        label.textColor = .label
        label.textAlignment = .center
        label.widthAnchor.constraint(equalToConstant: 30).isActive = true
        return label
    }()
    
    private let plusButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = Theme.accentColor
        return btn
    }()
    
    private let deleteButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.tintColor = Theme.spicyRed
        return btn
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
        
        // Text stack
        let textStack = UIStackView(arrangedSubviews: [itemNameLabel, priceLabel, subtotalLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        
        // Stepper stack
        let stepperStack = UIStackView(arrangedSubviews: [minusButton, quantityLabel, plusButton])
        stepperStack.translatesAutoresizingMaskIntoConstraints = false
        stepperStack.axis = .horizontal
        stepperStack.spacing = 4
        stepperStack.alignment = .center
        
        containerView.addSubview(textStack)
        containerView.addSubview(stepperStack)
        containerView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            textStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: stepperStack.leadingAnchor, constant: -12),
            
            stepperStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stepperStack.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            
            deleteButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24),
            
            minusButton.widthAnchor.constraint(equalToConstant: 26),
            minusButton.heightAnchor.constraint(equalToConstant: 26),
            plusButton.widthAnchor.constraint(equalToConstant: 26),
            plusButton.heightAnchor.constraint(equalToConstant: 26),
        ])
        
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(with cartItem: CartItem) {
        itemNameLabel.text = cartItem.foodItem.name
        priceLabel.text = cartItem.foodItem.formattedPrice
        currentQuantity = cartItem.quantity
        quantityLabel.text = "\(cartItem.quantity)"
        subtotalLabel.text = "Subtotal: \(cartItem.formattedSubtotal)"
    }
    
    // MARK: - Actions
    
    @objc private func minusTapped() {
        currentQuantity = max(1, currentQuantity - 1)
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }
    
    @objc private func plusTapped() {
        currentQuantity += 1
        quantityLabel.text = "\(currentQuantity)"
        onQuantityChanged?(currentQuantity)
    }
    
    @objc private func deleteTapped() {
        onRemove?()
    }
}
