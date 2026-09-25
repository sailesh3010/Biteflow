import Foundation

/// Real-time kitchen & bistro operations status
struct BistroStatusResponse: Codable {
    let isRushHour: Bool
    let rushExtraMinutes: Int
    let activeKitchenTicketsCount: Int
    let isOnlineOrderingEnabled: Bool
    let estimatedWaitMinutes: Int
    let announcementMessage: String?
}

/// Request to toggle kitchen rush mode
struct ToggleRushModeRequest: Codable {
    let enabled: Bool
    let extraMinutes: Int?
}

/// Request to update item availability (86 toggle)
struct ToggleItem86Request: Codable {
    let isAvailable: Bool?
    let stockCount: Int?
}

/// Shift end or daily Z-Report with sales analytics
struct ZReportResponse: Codable {
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
    
    var formattedGrossSales: String { String(format: "$%.2f", grossSales) }
    var formattedNetSales: String { String(format: "$%.2f", netSales) }
    var formattedTaxCollected: String { String(format: "$%.2f", taxCollected) }
    var formattedAvgTicket: String { String(format: "$%.2f", averageTicketSize) }
}

struct TopSellingDishDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let categoryName: String
    let quantitySold: Int
    let revenue: Double
    
    var formattedRevenue: String { String(format: "$%.2f", revenue) }
}
