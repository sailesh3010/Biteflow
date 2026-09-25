import Foundation

/// Local cart item wrapping a food item with quantity
struct CartItem: Identifiable {
    let id: UUID
    let foodItem: FoodItemResponse
    var quantity: Int
    var specialNotes: String
    
    var subtotal: Double {
        foodItem.price * Double(quantity)
    }
    
    var formattedSubtotal: String {
        String(format: "$%.2f", subtotal)
    }
    
    init(foodItem: FoodItemResponse, quantity: Int = 1, specialNotes: String = "") {
        self.id = UUID()
        self.foodItem = foodItem
        self.quantity = quantity
        self.specialNotes = specialNotes
    }
}
