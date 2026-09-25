import UIKit

/// Main menu screen with category filter strip, food item grid, 86'd status, and live kitchen rush banner
final class MenuViewController: UIViewController {
    
    // MARK: - Data
    
    private var categories: [CategoryResponse] = []
    private var allItems: [FoodItemResponse] = []
    private var filteredItems: [FoodItemResponse] = []
    private var selectedCategoryIndex: Int = 0  // 0 = "All"
    private var bistroStatus: BistroStatusResponse?
    
    // MARK: - UI Elements
    
    // Kitchen Rush Banner (Bistro Operation Feature)
    private let rushBanner: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.18)
        v.layer.cornerRadius = 10
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.systemOrange.cgColor
        v.isHidden = true
        return v
    }()
    
    private let rushIcon: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "🔥"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private let rushLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemOrange
        label.numberOfLines = 1
        label.text = "Kitchen Rush Active: High volume, prep times +15m"
        return label
    }()
    
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
    
    private let refreshControl = UIRefreshControl()
    
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
    
    private var rushBannerHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
        fetchMenu()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(cartDidChange),
            name: CartManager.cartDidChangeNotification, object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchBistroStatus()
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
        
        rushBanner.addSubview(rushIcon)
        rushBanner.addSubview(rushLabel)
        
        view.addSubview(rushBanner)
        view.addSubview(searchBar)
        view.addSubview(categoryCollectionView)
        view.addSubview(foodCollectionView)
        view.addSubview(activityIndicator)
        view.addSubview(emptyLabel)
        
        searchBar.delegate = self
        
        foodCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        rushBannerHeightConstraint = rushBanner.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            rushBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            rushBanner.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            rushBanner.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            rushBannerHeightConstraint!,
            
            rushIcon.leadingAnchor.constraint(equalTo: rushBanner.leadingAnchor, constant: 10),
            rushIcon.centerYAnchor.constraint(equalTo: rushBanner.centerYAnchor),
            
            rushLabel.leadingAnchor.constraint(equalTo: rushIcon.trailingAnchor, constant: 8),
            rushLabel.trailingAnchor.constraint(equalTo: rushBanner.trailingAnchor, constant: -10),
            rushLabel.centerYAnchor.constraint(equalTo: rushBanner.centerYAnchor),
            
            searchBar.topAnchor.constraint(equalTo: rushBanner.bottomAnchor, constant: 4),
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
                async let categoriesTask = APIService.shared.fetchCategoriesWithItems()
                async let statusTask = APIService.shared.fetchBistroStatus()
                
                let (categoriesWithItems, status) = try await (categoriesTask, statusTask)
                
                self.categories = categoriesWithItems
                self.allItems = categoriesWithItems.flatMap { $0.items ?? [] }
                self.filteredItems = self.allItems
                self.bistroStatus = status
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.updateRushBanner(status: status)
                    self.categoryCollectionView.reloadData()
                    self.foodCollectionView.reloadData()
                    self.updateEmptyState()
                }
            } catch {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.refreshControl.endRefreshing()
                    self.showError(error)
                }
            }
        }
    }
    
    private func fetchBistroStatus() {
        Task {
            if let status = try? await APIService.shared.fetchBistroStatus() {
                self.bistroStatus = status
                DispatchQueue.main.async {
                    self.updateRushBanner(status: status)
                }
            }
        }
    }
    
    @objc private func handleRefresh() {
        fetchMenu()
    }
    
    private func updateRushBanner(status: BistroStatusResponse) {
        let isRush = status.isRushHour
        rushBanner.isHidden = !isRush
        rushBannerHeightConstraint?.constant = isRush ? 36 : 0
        if isRush {
            rushLabel.text = status.announcementMessage ?? "🔥 Peak Rush: +15m kitchen prep time"
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Filtering
    
    private func filterItems() {
        var items = allItems
        
        if selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count {
            let selectedCategory = categories[selectedCategoryIndex - 1]
            items = selectedCategory.items ?? []
        }
        
        if let query = searchBar.text, !query.isEmpty {
            items = items.filter { item in
                item.name.localizedCaseInsensitiveContains(query) ||
                item.description.localizedCaseInsensitiveContains(query)
            }
        }
        
        filteredItems = items
        foodCollectionView.reloadData()
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        emptyLabel.isHidden = !filteredItems.isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func cartDidChange() {
        let count = CartManager.shared.itemCount
        navigationController?.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Network Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchMenu()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count + 1 // +1 for "All"
        } else {
            return filteredItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryPillCell.reuseID, for: indexPath
            ) as? CategoryPillCell else { return UICollectionViewCell() }
            
            let isSelected = indexPath.item == selectedCategoryIndex
            
            if indexPath.item == 0 {
                cell.configure(name: "All", icon: "🍽️", isSelected: isSelected)
            } else {
                let category = categories[indexPath.item - 1]
                cell.configure(name: category.name, icon: category.icon, isSelected: isSelected)
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FoodCardCell.reuseID, for: indexPath
            ) as? FoodCardCell else { return UICollectionViewCell() }
            
            let item = filteredItems[indexPath.item]
            cell.configure(with: item)
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategoryIndex = indexPath.item
            categoryCollectionView.reloadData()
            filterItems()
        } else {
            let item = filteredItems[indexPath.item]
            let detailVC = FoodDetailViewController(foodItem: item)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - FoodCardCellDelegate

extension MenuViewController: FoodCardCellDelegate {
    func foodCardCellDidTapAdd(_ cell: FoodCardCell, item: FoodItemResponse) {
        guard item.isAvailable else { return }
        CartManager.shared.addItem(item)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
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
}
