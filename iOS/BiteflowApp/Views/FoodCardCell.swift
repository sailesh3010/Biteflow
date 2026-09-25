import UIKit

/// Protocol to handle add-to-cart taps from the food card
protocol FoodCardCellDelegate: AnyObject {
    func foodCardCellDidTapAdd(_ cell: FoodCardCell, item: FoodItemResponse)
}

/// Rich food item card with image, badges, 86'd status, and add-to-cart button
final class FoodCardCell: UICollectionViewCell {
    
    static let reuseID = "FoodCardCell"
    
    weak var delegate: FoodCardCellDelegate?
    private var foodItem: FoodItemResponse?
    
    // MARK: - UI Elements
    
    private let cardView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = Theme.cardBackground
        v.layer.cornerRadius = Theme.cornerRadius
        return v
    }()
    
    private let foodImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Theme.cornerRadius
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.backgroundColor = UIColor.systemGray5
        return iv
    }()
    
    // 86'd (Sold Out) overlay badge for Bistro Operations
    private let eightySixedOverlay: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemRed.withAlphaComponent(0.88)
        v.layer.cornerRadius = 6
        v.isHidden = true
        return v
    }()
    
    private let eightySixedLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .black)
        label.textColor = .white
        label.text = "86'D · SOLD OUT"
        label.textAlignment = .center
        return label
    }()
    
    private let ratingBadge: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        v.layer.cornerRadius = 10
        return v
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 11)
        label.textColor = .white
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.headingFont(size: 15)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let metaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 11)
        label.textColor = Theme.secondaryText
        return label
    }()
    
    private let badgeStack: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 6
        return sv
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.priceFont(size: 16)
        label.textColor = Theme.accentColor
        return label
    }()
    
    private let addButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        btn.tintColor = Theme.accentColor
        btn.contentHorizontalAlignment = .fill
        btn.contentVerticalAlignment = .fill
        return btn
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        contentView.addSubview(cardView)
        Theme.applyCardShadow(to: cardView.layer)
        
        cardView.pinToSuperview()
        
        // Image
        cardView.addSubview(foodImageView)
        NSLayoutConstraint.activate([
            foodImageView.topAnchor.constraint(equalTo: cardView.topAnchor),
            foodImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            foodImageView.heightAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.65)
        ])
        
        // 86'd Overlay
        foodImageView.addSubview(eightySixedOverlay)
        eightySixedOverlay.addSubview(eightySixedLabel)
        NSLayoutConstraint.activate([
            eightySixedOverlay.centerYAnchor.constraint(equalTo: foodImageView.centerYAnchor),
            eightySixedOverlay.centerXAnchor.constraint(equalTo: foodImageView.centerXAnchor),
            eightySixedOverlay.leadingAnchor.constraint(greaterThanOrEqualTo: foodImageView.leadingAnchor, constant: 12),
            eightySixedOverlay.trailingAnchor.constraint(lessThanOrEqualTo: foodImageView.trailingAnchor, constant: -12),
            eightySixedOverlay.heightAnchor.constraint(equalToConstant: 26),
            
            eightySixedLabel.topAnchor.constraint(equalTo: eightySixedOverlay.topAnchor),
            eightySixedLabel.bottomAnchor.constraint(equalTo: eightySixedOverlay.bottomAnchor),
            eightySixedLabel.leadingAnchor.constraint(equalTo: eightySixedOverlay.leadingAnchor, constant: 8),
            eightySixedLabel.trailingAnchor.constraint(equalTo: eightySixedOverlay.trailingAnchor, constant: -8)
        ])
        
        // Rating badge overlay
        foodImageView.addSubview(ratingBadge)
        ratingBadge.addSubview(ratingLabel)
        NSLayoutConstraint.activate([
            ratingBadge.topAnchor.constraint(equalTo: foodImageView.topAnchor, constant: 8),
            ratingBadge.trailingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: -8),
            ratingLabel.topAnchor.constraint(equalTo: ratingBadge.topAnchor, constant: 4),
            ratingLabel.bottomAnchor.constraint(equalTo: ratingBadge.bottomAnchor, constant: -4),
            ratingLabel.leadingAnchor.constraint(equalTo: ratingBadge.leadingAnchor, constant: 8),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingBadge.trailingAnchor, constant: -8),
        ])
        
        // Text content
        let textStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel, badgeStack])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        
        cardView.addSubview(textStack)
        NSLayoutConstraint.activate([
            textStack.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 10),
            textStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
        ])
        
        // Price + Add button row
        cardView.addSubview(priceLabel)
        cardView.addSubview(addButton)
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 10),
            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            addButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            addButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -8),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    
    func configure(with item: FoodItemResponse) {
        self.foodItem = item
        nameLabel.text = item.name
        priceLabel.text = item.formattedPrice
        metaLabel.text = "\(item.calorieDisplay) · \(item.prepTimeDisplay)"
        ratingLabel.text = "⭐ \(String(format: "%.1f", item.rating))"
        
        // Handle 86'd status (Sold Out)
        let is86d = !item.isAvailable
        eightySixedOverlay.isHidden = !is86d
        foodImageView.alpha = is86d ? 0.35 : 1.0
        nameLabel.textColor = is86d ? .secondaryLabel : .label
        
        if is86d {
            addButton.isEnabled = false
            addButton.setImage(UIImage(systemName: "slash.circle.fill"), for: .normal)
            addButton.tintColor = .systemGray4
        } else {
            addButton.isEnabled = true
            addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            addButton.tintColor = Theme.accentColor
        }
        
        // Reset badges
        badgeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Low Stock Urgency Badge
        if let lowStockText = item.lowStockDisplay, !is86d {
            badgeStack.addArrangedSubview(makeBadge(text: lowStockText, color: UIColor.systemOrange))
        }
        if item.isVegetarian {
            badgeStack.addArrangedSubview(makeBadge(text: "🌱 Veg", color: Theme.vegGreen))
        }
        if item.isSpicy {
            badgeStack.addArrangedSubview(makeBadge(text: "🌶️ Spicy", color: Theme.spicyRed))
        }
        
        // Load image from URL
        loadImage(from: item.imageURL)
    }
    
    // MARK: - Helpers
    
    private func makeBadge(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = Theme.captionFont(size: 10)
        label.textColor = color
        label.backgroundColor = color.withAlphaComponent(0.12)
        label.textAlignment = .center
        label.layer.cornerRadius = 6
        label.clipsToBounds = true
        
        let container = UIView()
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            label.heightAnchor.constraint(equalToConstant: 20),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
        ])
        
        return container
    }
    
    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.foodImageView.image = image
            }
        }.resume()
    }
    
    @objc private func addTapped() {
        guard let item = foodItem, item.isAvailable else { return }
        addButton.addBounceAnimation()
        delegate?.foodCardCellDidTapAdd(self, item: item)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        foodImageView.image = nil
        foodImageView.alpha = 1.0
        eightySixedOverlay.isHidden = true
        addButton.isEnabled = true
        nameLabel.textColor = .label
        badgeStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
