import Foundation

/// Manages the in-memory shopping cart state
/// Uses the Observer pattern (NotificationCenter) to broadcast cart changes to all screens
final class CartManager {
    
    static let shared = CartManager()
    
    /// Posted whenever the cart contents change
    static let cartDidChangeNotification = Notification.Name("CartManager.cartDidChange")
    
    private(set) var items: [CartItem] = []
    
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
        subtotal >= 30.0 ? 0.0 : 3.99
    }
    
    var total: Double {
        ((subtotal + tax + deliveryFee) * 100).rounded() / 100
    }
    
    var formattedSubtotal: String { String(format: "$%.2f", subtotal) }
    var formattedTax: String { String(format: "$%.2f", tax) }
    var formattedDeliveryFee: String { deliveryFee == 0 ? "Free" : String(format: "$%.2f", deliveryFee) }
    var formattedTotal: String { String(format: "$%.2f", total) }
    
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
        
        return CreateOrderRequest(
            customerName: customerName,
            customerPhone: customerPhone,
            deliveryAddress: deliveryAddress,
            specialInstructions: specialInstructions,
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
