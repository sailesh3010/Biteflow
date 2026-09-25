import Foundation

/// Represents a food category from the API
struct CategoryResponse: Codable, Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let sortOrder: Int
    let items: [FoodItemResponse]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon
        case sortOrder = "sortOrder"
        case items
    }
}
