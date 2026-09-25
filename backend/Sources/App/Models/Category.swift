import Fluent
import Vapor

/// Represents a food category (e.g., Burgers, Pizzas, Desserts, Beverages)
final class Category: Model, Content, @unchecked Sendable {
    static let schema = "categories"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "icon")
    var icon: String
    
    @Field(key: "sort_order")
    var sortOrder: Int
    
    @Children(for: \.$category)
    var items: [FoodItem]
    
    init() {}
    
    init(id: UUID? = nil, name: String, icon: String, sortOrder: Int) {
        self.id = id
        self.name = name
        self.icon = icon
        self.sortOrder = sortOrder
    }
}
