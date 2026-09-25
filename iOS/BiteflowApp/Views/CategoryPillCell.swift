import UIKit

/// Horizontal scrollable pill/chip for category filtering
final class CategoryPillCell: UICollectionViewCell {
    
    static let reuseID = "CategoryPillCell"
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.layer.borderWidth = 1.5
        v.layer.borderColor = Theme.accentColor.cgColor
        v.backgroundColor = .clear
        return v
    }()
    
    private let iconLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Theme.captionFont(size: 13)
        label.textColor = .label
        return label
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 6
        sv.alignment = .center
        return sv
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
        contentView.addSubview(containerView)
        containerView.pinToSuperview()
        
        stackView.addArrangedSubview(iconLabel)
        stackView.addArrangedSubview(nameLabel)
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with category: CategoryResponse, isSelected: Bool) {
        iconLabel.text = category.icon
        nameLabel.text = category.name
        
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.containerView.backgroundColor = Theme.accentColor
                self.containerView.layer.borderColor = Theme.accentColor.cgColor
                self.nameLabel.textColor = .white
            } else {
                self.containerView.backgroundColor = .clear
                self.containerView.layer.borderColor = Theme.accentColor.cgColor
                self.nameLabel.textColor = .label
            }
        }
    }
    
    /// Configure as the "All" category pill
    func configureAsAll(isSelected: Bool) {
        iconLabel.text = "🍽️"
        nameLabel.text = "All"
        
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                self.containerView.backgroundColor = Theme.accentColor
                self.containerView.layer.borderColor = Theme.accentColor.cgColor
                self.nameLabel.textColor = .white
            } else {
                self.containerView.backgroundColor = .clear
                self.containerView.layer.borderColor = Theme.accentColor.cgColor
                self.nameLabel.textColor = .label
            }
        }
    }
}
