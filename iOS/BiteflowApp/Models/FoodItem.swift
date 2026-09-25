import Foundation

/// Represents a food item from the API
struct FoodItemResponse: Codable, Identifiable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    let calories: Int
    let prepTimeMinutes: Int
    let isVegetarian: Bool
    let isSpicy: Bool
    var isAvailable: Bool
    var stockCount: Int?
    let pairingName: String?
    let pairingPrice: Double?
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price
        case imageURL = "imageURL"
        case calories
        case prepTimeMinutes = "prepTimeMinutes"
        case isVegetarian = "isVegetarian"
        case isSpicy = "isSpicy"
        case isAvailable = "isAvailable"
        case stockCount = "stockCount"
        case pairingName = "pairingName"
        case pairingPrice = "pairingPrice"
        case rating
    }
    
    /// Formatted price string
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
    
    /// Prep time display string
    var prepTimeDisplay: String {
        "\(prepTimeMinutes) min"
    }
    
    /// Calorie display string
    var calorieDisplay: String {
        "\(calories) cal"
    }
    
    /// Urgent stock status badge (for restaurant operations)
    var isLowStock: Bool {
        isAvailable && (stockCount != nil && stockCount! <= 5)
    }
    
    var lowStockDisplay: String? {
        guard let count = stockCount, count <= 5 else { return nil }
        return "🔥 Only \(count) left!"
    }
    
    var formattedPairingPrice: String? {
        guard let p = pairingPrice else { return nil }
        return String(format: "+$%.2f", p)
    }
}
