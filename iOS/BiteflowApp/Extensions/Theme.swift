import UIKit

/// Central design system for the Biteflow app
enum Theme {
    
    // MARK: - Colors
    
    /// Warm orange-amber accent — the signature Biteflow color
    static let accentColor = UIColor(red: 0.96, green: 0.52, blue: 0.12, alpha: 1.0) // #F58420
    
    /// Deeper orange for pressed/active states
    static let accentDark = UIColor(red: 0.85, green: 0.40, blue: 0.08, alpha: 1.0)
    
    /// Success green for order confirmation and availability
    static let successColor = UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1.0)
    
    /// Warm red for spicy indicators and destructive actions
    static let spicyRed = UIColor(red: 0.93, green: 0.26, blue: 0.21, alpha: 1.0)
    
    /// Vegetarian badge green
    static let vegGreen = UIColor(red: 0.18, green: 0.69, blue: 0.29, alpha: 1.0)
    
    /// Soft card background (adapts to dark mode)
    static var cardBackground: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1.0)
                : UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1.0)
        }
    }
    
    /// Main background
    static var background: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1.0)
                : UIColor.white
        }
    }
    
    /// Subtle separator / divider color
    static var separator: UIColor {
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white.withAlphaComponent(0.08)
                : UIColor.black.withAlphaComponent(0.06)
        }
    }
    
    /// Secondary text color
    static let secondaryText = UIColor.secondaryLabel
    
    // MARK: - Typography
    
    static func titleFont(size: CGFloat = 24) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }
    
    static func headingFont(size: CGFloat = 18) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }
    
    static func bodyFont(size: CGFloat = 15) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }
    
    static func captionFont(size: CGFloat = 12) -> UIFont {
        .systemFont(ofSize: size, weight: .medium)
    }
    
    static func priceFont(size: CGFloat = 17) -> UIFont {
        .monospacedDigitSystemFont(ofSize: size, weight: .bold)
    }
    
    // MARK: - Layout Constants
    
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let itemSpacing: CGFloat = 12
    
    // MARK: - Shadows
    
    static func applyCardShadow(to layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.08
        layer.masksToBounds = false
    }
}
