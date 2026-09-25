import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        // MARK: - Tab Bar Controller Setup
        let tabBarController = UITabBarController()
        
        // 1. Menu Tab
        let menuVC = MenuViewController()
        let menuNav = UINavigationController(rootViewController: menuVC)
        menuNav.tabBarItem = UITabBarItem(
            title: "Menu",
            image: UIImage(systemName: "menucard"),
            selectedImage: UIImage(systemName: "menucard.fill")
        )
        
        // 2. Cart Tab
        let cartVC = CartViewController()
        let cartNav = UINavigationController(rootViewController: cartVC)
        cartNav.tabBarItem = UITabBarItem(
            title: "Cart",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )
        
        // 3. Orders Tab
        let ordersVC = OrderStatusViewController()
        let ordersNav = UINavigationController(rootViewController: ordersVC)
        ordersNav.tabBarItem = UITabBarItem(
            title: "Orders",
            image: UIImage(systemName: "clock.arrow.circlepath"),
            selectedImage: UIImage(systemName: "clock.arrow.circlepath")
        )
        
        // 4. Bistro Manager Tab (Z-Report & Operations)
        let portalVC = BistroPortalViewController()
        let portalNav = UINavigationController(rootViewController: portalVC)
        portalNav.tabBarItem = UITabBarItem(
            title: "Manager",
            image: UIImage(systemName: "chart.bar.doc.horizontal"),
            selectedImage: UIImage(systemName: "chart.bar.doc.horizontal.fill")
        )
        
        tabBarController.viewControllers = [menuNav, cartNav, ordersNav, portalNav]
        tabBarController.selectedIndex = 0
        
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
