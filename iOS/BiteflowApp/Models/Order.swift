import Foundation

/// Represents an order response from the API
struct OrderResponse: Codable, Identifiable {
    let id: UUID
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let subtotal: Double
    let tax: Double
    let deliveryFee: Double
    let total: Double
    let specialInstructions: String
    let diningOption: String
    let tableNumber: String?
    let splitCount: Int
    let perPersonSplit: Double
    let status: String
    let statusDisplayName: String
    let items: [OrderItemResponse]
    let createdAt: Date?
    
    var formattedTotal: String {
        String(format: "$%.2f", total)
    }
    
    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
    
    var formattedTax: String {
        String(format: "$%.2f", tax)
    }
    
    var formattedDeliveryFee: String {
        deliveryFee == 0 ? "Free" : String(format: "$%.2f", deliveryFee)
    }
    
    var formattedPerPersonSplit: String {
        String(format: "$%.2f / person", perPersonSplit)
    }
    
    var diningOptionDisplay: String {
        switch diningOption {
        case "dine_in":
            return "🍽️ Dine-In (\(tableNumber ?? "Table"))"
        case "pickup":
            return "🛍️ Takeout / Pickup"
        default:
            return "🛵 Delivery"
        }
    }
}

struct OrderItemResponse: Codable, Identifiable {
    let id: UUID
    let itemName: String
    let quantity: Int
    let unitPrice: Double
    let specialNotes: String
    
    var formattedPrice: String {
        String(format: "$%.2f", unitPrice * Double(quantity))
    }
}

/// Request body sent to create a new order
struct CreateOrderRequest: Codable {
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let specialInstructions: String
    let diningOption: String?
    let tableNumber: String?
    let splitCount: Int?
    let items: [CreateOrderItemRequest]
}

struct CreateOrderItemRequest: Codable {
    let foodItemID: UUID
    let quantity: Int
    let specialNotes: String
}
