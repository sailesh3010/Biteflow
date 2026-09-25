import Fluent
import Vapor

/// Represents an individual item within an order
final class OrderItem: Model, Content, @unchecked Sendable {
    static let schema = "order_items"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "order_id")
    var order: Order
    
    @Parent(key: "food_item_id")
    var foodItem: FoodItem
    
    @Field(key: "quantity")
    var quantity: Int
    
    @Field(key: "unit_price")
    var unitPrice: Double
    
    @Field(key: "item_name")
    var itemName: String
    
    @Field(key: "special_notes")
    var specialNotes: String
    
    init() {}
    
    init(
        id: UUID? = nil,
        orderID: UUID,
        foodItemID: UUID,
        quantity: Int,
        unitPrice: Double,
        itemName: String,
        specialNotes: String = ""
    ) {
        self.id = id
        self.$order.id = orderID
        self.$foodItem.id = foodItemID
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.itemName = itemName
        self.specialNotes = specialNotes
    }
}
