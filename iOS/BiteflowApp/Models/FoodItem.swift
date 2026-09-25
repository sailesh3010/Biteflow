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
    let isAvailable: Bool
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, price
        case imageURL = "imageURL"
        case calories
        case prepTimeMinutes = "prepTimeMinutes"
        case isVegetarian = "isVegetarian"
        case isSpicy = "isSpicy"
        case isAvailable = "isAvailable"
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
}
