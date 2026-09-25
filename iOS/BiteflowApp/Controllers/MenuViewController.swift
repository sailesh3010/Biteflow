import UIKit

/// Main menu screen with category filter strip and food item grid
final class MenuViewController: UIViewController {
    
    // MARK: - Data
    
    private var categories: [CategoryResponse] = []
    private var allItems: [FoodItemResponse] = []
    private var filteredItems: [FoodItemResponse] = []
    private var selectedCategoryIndex: Int = 0  // 0 = "All"
    
    // MARK: - UI Elements
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.placeholder = "Search burgers, pizzas, drinks..."
        sb.searchBarStyle = .minimal
        sb.backgroundImage = UIImage()
        return sb
    }()
    
    private lazy var categoryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(CategoryPillCell.self, forCellWithReuseIdentifier: CategoryPillCell.reuseID)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private lazy var foodCollectionView: UICollectionView = {
        let layout = createFoodGridLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(FoodCardCell.self, forCellWithReuseIdentifier: FoodCardCell.reuseID)
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        ai.color = Theme.accentColor
        return ai
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No items found"
        label.font = Theme.bodyFont(size: 16)
        label.textColor = Theme.secondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        fetchMenu()
        
        // Listen for cart changes to update badge
        NotificationCenter.default.addObserver(
            self, selector: #selector(cartDidChange),
            name: CartManager.cartDidChangeNotification, object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        title = "Biteflow"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupUI() {
        view.backgroundColor = Theme.background
        
        view.addSubview(searchBar)
        view.addSubview(categoryCollectionView)
        view.addSubview(foodCollectionView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoryCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50),
            
            foodCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8),
            foodCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            foodCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            foodCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: foodCollectionView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: foodCollectionView.centerYAnchor),
            
            emptyLabel.centerXAnchor.constraint(equalTo: foodCollectionView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: foodCollectionView.centerYAnchor),
        ])
    }
    
    private func createFoodGridLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .estimated(280)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(280)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    // MARK: - Networking
    
    private func fetchMenu() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let categoriesWithItems = try await APIService.shared.fetchCategoriesWithItems()
                self.categories = categoriesWithItems
                self.allItems = categoriesWithItems.flatMap { $0.items ?? [] }
                self.filteredItems = self.allItems
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.categoryCollectionView.reloadData()
                    self.foodCollectionView.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showError(error)
                }
            }
        }
    }
    
    // MARK: - Filtering
    
    private func filterItems() {
        if selectedCategoryIndex == 0 {
            // "All" selected
            filteredItems = allItems
        } else {
            let category = categories[selectedCategoryIndex - 1]
            filteredItems = category.items ?? []
        }
        
        // Apply search filter if search text exists
        if let searchText = searchBar.text, !searchText.isEmpty {
            filteredItems = filteredItems.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        foodCollectionView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyLabel.isHidden = !filteredItems.isEmpty
    }
    
    // MARK: - Helpers
    
    @objc private func cartDidChange() {
        // Update cart tab badge
        if let tabItems = tabBarController?.tabBar.items, tabItems.count > 1 {
            let count = CartManager.shared.itemCount
            tabItems[1].badgeValue = count > 0 ? "\(count)" : nil
            tabItems[1].badgeColor = Theme.accentColor
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchMenu()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showAddedToCartFeedback(for item: FoodItemResponse) {
        let banner = UILabel()
        banner.text = "✓ \(item.name) added to cart"
        banner.font = Theme.captionFont(size: 13)
        banner.textColor = .white
        banner.backgroundColor = Theme.successColor
        banner.textAlignment = .center
        banner.layer.cornerRadius = 20
        banner.clipsToBounds = true
        banner.alpha = 0
        banner.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            banner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            banner.heightAnchor.constraint(equalToConstant: 40),
            banner.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            banner.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            banner.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
        ])
        
        // Pad text
        banner.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        UIView.animate(withDuration: 0.3) {
            banner.alpha = 1
            banner.transform = CGAffineTransform(translationX: 0, y: -10)
        } completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5) {
                banner.alpha = 0
                banner.transform = .identity
            } completion: { _ in
                banner.removeFromSuperview()
            }
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension MenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count + 1  // +1 for "All"
        }
        return filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath
            ) as! CategoryPillCell
            
            if indexPath.item == 0 {
                cell.configureAsAll(isSelected: selectedCategoryIndex == 0)
            } else {
                cell.configure(
                    with: categories[indexPath.item - 1],
                    isSelected: selectedCategoryIndex == indexPath.item
                )
            }
            return cell
        }
        
        // Food grid
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: FoodCardCell.reuseID, for: indexPath
        ) as! FoodCardCell
        cell.configure(with: filteredItems[indexPath.item])
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.item
            categoryCollectionView.reloadData()
            filterItems()
            
            // Scroll selected pill into view
            categoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            return
        }
        
        // Navigate to food detail
        let item = filteredItems[indexPath.item]
        let detailVC = FoodDetailViewController(foodItem: item)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - FoodCardCellDelegate

extension MenuViewController: FoodCardCellDelegate {
    func foodCardCellDidTapAdd(_ cell: FoodCardCell, item: FoodItemResponse) {
        CartManager.shared.addItem(item)
        showAddedToCartFeedback(for: item)
    }
}

// MARK: - UISearchBarDelegate

extension MenuViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterItems()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterItems()
    }
}
