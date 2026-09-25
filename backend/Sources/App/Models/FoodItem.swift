import Fluent
import Vapor

/// Represents a food item on the menu
final class FoodItem: Model, Content, @unchecked Sendable {
    static let schema = "food_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "price")
    var price: Double
    
    @Field(key: "image_url")
    var imageURL: String
    
    @Field(key: "calories")
    var calories: Int
    
    @Field(key: "prep_time_minutes")
    var prepTimeMinutes: Int
    
    @Field(key: "is_vegetarian")
    var isVegetarian: Bool
    
    @Field(key: "is_spicy")
    var isSpicy: Bool
    
    @Field(key: "is_available")
    var isAvailable: Bool
    
    @Field(key: "rating")
    var rating: Double
    
    @Parent(key: "category_id")
    var category: Category
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        name: String,
        description: String,
        price: Double,
        imageURL: String,
        calories: Int,
        prepTimeMinutes: Int,
        isVegetarian: Bool,
        isSpicy: Bool,
        isAvailable: Bool = true,
        rating: Double,
        categoryID: UUID
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageURL = imageURL
        self.calories = calories
        self.prepTimeMinutes = prepTimeMinutes
        self.isVegetarian = isVegetarian
        self.isSpicy = isSpicy
        self.isAvailable = isAvailable
        self.rating = rating
        self.$category.id = categoryID
    }
}
