import Fluent
import Vapor

/// Represents a customer order
final class Order: Model, Content, @unchecked Sendable {
    static let schema = "orders"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "customer_name")
    var customerName: String
    
    @Field(key: "customer_phone")
    var customerPhone: String
    
    @Field(key: "delivery_address")
    var deliveryAddress: String
    
    @Field(key: "subtotal")
    var subtotal: Double
    
    @Field(key: "tax")
    var tax: Double
    
    @Field(key: "delivery_fee")
    var deliveryFee: Double
    
    @Field(key: "total")
    var total: Double
    
    @Field(key: "special_instructions")
    var specialInstructions: String
    
    @Enum(key: "status")
    var status: OrderStatus
    
    @Children(for: \.$order)
    var items: [OrderItem]
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(
        id: UUID? = nil,
        customerName: String,
        customerPhone: String,
        deliveryAddress: String,
        subtotal: Double,
        tax: Double,
        deliveryFee: Double,
        total: Double,
        specialInstructions: String = "",
        status: OrderStatus = .placed
    ) {
        self.id = id
        self.customerName = customerName
        self.customerPhone = customerPhone
        self.deliveryAddress = deliveryAddress
        self.subtotal = subtotal
        self.tax = tax
        self.deliveryFee = deliveryFee
        self.total = total
        self.specialInstructions = specialInstructions
        self.status = status
    }
}

/// Order lifecycle status
enum OrderStatus: String, Codable, CaseIterable {
    case placed     = "placed"
    case confirmed  = "confirmed"
    case preparing  = "preparing"
    case ready      = "ready"
    case outForDelivery = "out_for_delivery"
    case delivered  = "delivered"
    case cancelled  = "cancelled"
    
    var displayName: String {
        switch self {
        case .placed:         return "Order Placed"
        case .confirmed:      return "Confirmed"
        case .preparing:      return "Preparing"
        case .ready:          return "Ready for Pickup"
        case .outForDelivery: return "Out for Delivery"
        case .delivered:      return "Delivered"
        case .cancelled:      return "Cancelled"
        }
    }
}
