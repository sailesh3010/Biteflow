import Vapor

// MARK: - Request DTOs

/// Used by the iOS app to send a new order to the backend
struct CreateOrderRequest: Content {
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let specialInstructions: String
    let items: [CreateOrderItemRequest]
}

struct CreateOrderItemRequest: Content {
    let foodItemID: UUID
    let quantity: Int
    let specialNotes: String
}

/// Used to update an order's status (e.g., from kitchen dashboard)
struct UpdateOrderStatusRequest: Content {
    let status: String
}

// MARK: - Response DTOs

/// Full order response with nested items
struct OrderResponse: Content {
    let id: UUID
    let customerName: String
    let customerPhone: String
    let deliveryAddress: String
    let subtotal: Double
    let tax: Double
    let deliveryFee: Double
    let total: Double
    let specialInstructions: String
    let status: String
    let statusDisplayName: String
    let items: [OrderItemResponse]
    let createdAt: Date?
    
    init(from order: Order, items: [OrderItemResponse]) {
        self.id = order.id!
        self.customerName = order.customerName
        self.customerPhone = order.customerPhone
        self.deliveryAddress = order.deliveryAddress
        self.subtotal = order.subtotal
        self.tax = order.tax
        self.deliveryFee = order.deliveryFee
        self.total = order.total
        self.specialInstructions = order.specialInstructions
        self.status = order.status.rawValue
        self.statusDisplayName = order.status.displayName
        self.items = items
        self.createdAt = order.createdAt
    }
}

struct OrderItemResponse: Content {
    let id: UUID
    let itemName: String
    let quantity: Int
    let unitPrice: Double
    let specialNotes: String
    
    init(from orderItem: OrderItem) {
        self.id = orderItem.id!
        self.itemName = orderItem.itemName
        self.quantity = orderItem.quantity
        self.unitPrice = orderItem.unitPrice
        self.specialNotes = orderItem.specialNotes
    }
}

/// Category with nested food items
struct CategoryWithItemsResponse: Content {
    let id: UUID
    let name: String
    let icon: String
    let sortOrder: Int
    let items: [FoodItem]
    
    init(from category: Category) {
        self.id = category.id!
        self.name = category.name
        self.icon = category.icon
        self.sortOrder = category.sortOrder
        self.items = category.items
    }
}
