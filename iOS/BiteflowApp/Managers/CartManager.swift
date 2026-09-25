import Foundation

/// Dining mode selected by customer
enum DiningOption: String, CaseIterable {
    case dineIn = "dine_in"
    case pickup = "pickup"
    case delivery = "delivery"
    
    var title: String {
        switch self {
        case .dineIn: return "🍽️ Dine-In"
        case .pickup: return "🛍️ Takeout"
        case .delivery: return "🛵 Delivery"
        }
    }
}

/// Manages the in-memory shopping cart state
/// Uses the Observer pattern (NotificationCenter) to broadcast cart changes to all screens
final class CartManager {
    
    static let shared = CartManager()
    
    /// Posted whenever the cart contents change
    static let cartDidChangeNotification = Notification.Name("CartManager.cartDidChange")
    
    private(set) var items: [CartItem] = []
    
    // Bistro operations state
    var selectedDiningOption: DiningOption = .dineIn {
        didSet { notifyCartChange() }
    }
    var tableNumber: String = "Table 4" {
        didSet { notifyCartChange() }
    }
    var splitCount: Int = 1 {
        didSet { notifyCartChange() }
    }
    
    private init() {}
    
    // MARK: - Computed Properties
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }
    
    var tax: Double {
        (subtotal * 0.08 * 100).rounded() / 100  // 8% tax, rounded to cents
    }
    
    var deliveryFee: Double {
        // Free delivery for dine-in, pickup, or delivery orders >= $30
        if selectedDiningOption == .dineIn || selectedDiningOption == .pickup || subtotal >= 30.0 {
            return 0.0
        }
        return 3.99
    }
    
    var total: Double {
        ((subtotal + tax + deliveryFee) * 100).rounded() / 100
    }
    
    var perPersonSplit: Double {
        let count = max(splitCount, 1)
        return ((total / Double(count)) * 100).rounded() / 100
    }
    
    var formattedSubtotal: String { String(format: "$%.2f", subtotal) }
    var formattedTax: String { String(format: "$%.2f", tax) }
    var formattedDeliveryFee: String { deliveryFee == 0 ? "Free ($0.00)" : String(format: "$%.2f", deliveryFee) }
    var formattedTotal: String { String(format: "$%.2f", total) }
    var formattedPerPersonSplit: String { String(format: "$%.2f / person", perPersonSplit) }
    
    var isEmpty: Bool { items.isEmpty }
    
    // MARK: - Cart Operations
    
    /// Add a food item to the cart. If it already exists, increment quantity.
    func addItem(_ foodItem: FoodItemResponse, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.foodItem.id == foodItem.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(foodItem: foodItem, quantity: quantity))
        }
        notifyCartChange()
    }
    
    /// Add a custom pairing item or side (Upsell feature)
    func addPairing(name: String, price: Double) {
        let pairingItem = FoodItemResponse(
            id: UUID(),
            name: name,
            description: "Chef's curated bistro pairing",
            price: price,
            imageURL: "https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400",
            calories: 150,
            prepTimeMinutes: 5,
            isVegetarian: true,
            isSpicy: false,
            isAvailable: true,
            stockCount: nil,
            pairingName: nil,
            pairingPrice: nil,
            rating: 4.9
        )
        addItem(pairingItem, quantity: 1)
    }
    
    /// Remove a food item entirely from the cart
    func removeItem(_ foodItem: FoodItemResponse) {
        items.removeAll { $0.foodItem.id == foodItem.id }
        notifyCartChange()
    }
    
    /// Update the quantity of a specific item. Removes if quantity drops to 0.
    func updateQuantity(for foodItem: FoodItemResponse, quantity: Int) {
        if quantity <= 0 {
            removeItem(foodItem)
            return
        }
        if let index = items.firstIndex(where: { $0.foodItem.id == foodItem.id }) {
            items[index].quantity = quantity
        }
        notifyCartChange()
    }
    
    /// Get the quantity of a specific food item in the cart
    func quantity(of foodItem: FoodItemResponse) -> Int {
        items.first(where: { $0.foodItem.id == foodItem.id })?.quantity ?? 0
    }
    
    /// Clear the entire cart (e.g., after successful order placement)
    func clearCart() {
        items.removeAll()
        splitCount = 1
        notifyCartChange()
    }
    
    /// Build the API request payload from current cart state
    func buildOrderRequest(
        customerName: String,
        customerPhone: String,
        deliveryAddress: String,
        specialInstructions: String = ""
    ) -> CreateOrderRequest {
        let orderItems = items.map { cartItem in
            CreateOrderItemRequest(
                foodItemID: cartItem.foodItem.id,
                quantity: cartItem.quantity,
                specialNotes: cartItem.specialNotes
            )
        }
        
        let destination = selectedDiningOption == .dineIn
            ? "Table \(tableNumber)"
            : (selectedDiningOption == .pickup ? "Takeout Pickup Counter" : deliveryAddress)
        
        return CreateOrderRequest(
            customerName: customerName,
            customerPhone: customerPhone,
            deliveryAddress: destination,
            specialInstructions: specialInstructions,
            diningOption: selectedDiningOption.rawValue,
            tableNumber: selectedDiningOption == .dineIn ? tableNumber : nil,
            splitCount: splitCount,
            items: orderItems
        )
    }
    
    // MARK: - Private
    
    private func notifyCartChange() {
        NotificationCenter.default.post(
            name: CartManager.cartDidChangeNotification,
            object: nil
        )
    }
}
