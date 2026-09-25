import Vapor

// MARK: - Bistro Operational State DTOs

/// Real-time kitchen & bistro status
struct BistroStatusResponse: Content {
    let isRushHour: Bool
    let rushExtraMinutes: Int
    let activeKitchenTicketsCount: Int
    let isOnlineOrderingEnabled: Bool
    let estimatedWaitMinutes: Int
    let announcementMessage: String?
}

/// Request to toggle kitchen rush mode
struct ToggleRushModeRequest: Content {
    let enabled: Bool
    let extraMinutes: Int?
}

/// Request to update item availability (86 toggle)
struct ToggleItem86Request: Content {
    let isAvailable: Bool?
    let stockCount: Int?
}

// MARK: - Manager Z-Report DTOs

/// Shift end or daily Z-Report with sales analytics
struct ZReportResponse: Content {
    let generatedAt: Date
    let grossSales: Double
    let netSales: Double
    let taxCollected: Double
    let totalOrders: Int
    let averageTicketSize: Double
    let activeKitchenTickets: Int
    let dineInOrdersCount: Int
    let pickupOrdersCount: Int
    let deliveryOrdersCount: Int
    let isRushHour: Bool
    let topSellingDishes: [TopSellingDishDTO]
    let eightySixedItemCount: Int
}

struct TopSellingDishDTO: Content {
    let id: UUID
    let name: String
    let categoryName: String
    let quantitySold: Int
    let revenue: Double
}
