import Vapor
import Fluent

/// In-memory synchronized bistro operational state
actor BistroStateManager {
    static let shared = BistroStateManager()
    
    private(set) var isRushHour: Bool = false
    private(set) var rushExtraMinutes: Int = 15
    private(set) var isOnlineOrderingEnabled: Bool = true
    
    func setRushHour(_ enabled: Bool, extraMinutes: Int = 15) {
        self.isRushHour = enabled
        self.rushExtraMinutes = extraMinutes
    }
    
    func setOnlineOrdering(_ enabled: Bool) {
        self.isOnlineOrderingEnabled = enabled
    }
}

/// Controller handling Bistro Operations, Rush Throttle, and Manager Z-Reports
struct BistroController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bistro = routes.grouped("bistro")
        
        // GET /api/v1/bistro/status — Live kitchen status & wait times
        bistro.get("status", use: getStatus)
        
        // POST /api/v1/bistro/rush-mode — Toggle peak rush mode
        bistro.post("rush-mode", use: toggleRushMode)
        
        // GET /api/v1/bistro/z-report — Shift end / daily sales analytics
        bistro.get("z-report", use: getZReport)
    }
    
    // MARK: - Handlers
    
    @Sendable
    func getStatus(req: Request) async throws -> BistroStatusResponse {
        let isRush = await BistroStateManager.shared.isRushHour
        let extraMins = await BistroStateManager.shared.rushExtraMinutes
        let onlineEnabled = await BistroStateManager.shared.isOnlineOrderingEnabled
        
        // Count active kitchen tickets
        let activeTickets = try await Order.query(on: req.db)
            .group(.or) { group in
                group.filter(\.$status == .placed)
                group.filter(\.$status == .confirmed)
                group.filter(\.$status == .preparing)
            }
            .count()
        
        let estimatedWait = 15 + (activeTickets * 2) + (isRush ? extraMins : 0)
        let message = isRush
            ? "🔥 Kitchen is in Peak Rush Mode (+15m prep time applied to all tickets)"
            : (activeTickets > 5 ? "⚡ High order volume in kitchen" : "✨ Kitchen operating at normal capacity")
        
        return BistroStatusResponse(
            isRushHour: isRush,
            rushExtraMinutes: extraMins,
            activeKitchenTicketsCount: activeTickets,
            isOnlineOrderingEnabled: onlineEnabled,
            estimatedWaitMinutes: estimatedWait,
            announcementMessage: message
        )
    }
    
    @Sendable
    func toggleRushMode(req: Request) async throws -> BistroStatusResponse {
        let input = try req.content.decode(ToggleRushModeRequest.self)
        let extra = input.extraMinutes ?? 15
        
        await BistroStateManager.shared.setRushHour(input.enabled, extraMinutes: extra)
        return try await getStatus(req: req)
    }
    
    @Sendable
    func getZReport(req: Request) async throws -> ZReportResponse {
        let orders = try await Order.query(on: req.db)
            .with(\.$items)
            .all()
        
        // Filter out cancelled orders for sales computation
        let validOrders = orders.filter { $0.status != .cancelled }
        
        let grossSales = validOrders.reduce(0.0) { $0 + $1.total }.rounded(toPlaces: 2)
        let netSales = validOrders.reduce(0.0) { $0 + $1.subtotal }.rounded(toPlaces: 2)
        let taxCollected = validOrders.reduce(0.0) { $0 + $1.tax }.rounded(toPlaces: 2)
        let totalOrdersCount = validOrders.count
        let avgTicket = totalOrdersCount > 0 ? (grossSales / Double(totalOrdersCount)).rounded(toPlaces: 2) : 0.0
        
        let activeTickets = orders.filter {
            $0.status == .placed || $0.status == .confirmed || $0.status == .preparing
        }.count
        
        let dineInCount = validOrders.filter { $0.diningOption == "dine_in" }.count
        let pickupCount = validOrders.filter { $0.diningOption == "pickup" }.count
        let deliveryCount = validOrders.filter { $0.diningOption == "delivery" }.count
        
        // Aggregate top selling dishes
        var itemQuantities: [String: (count: Int, revenue: Double, id: UUID)] = [:]
        for order in validOrders {
            for item in order.items {
                let existing = itemQuantities[item.itemName] ?? (0, 0.0, item.$foodItem.id)
                itemQuantities[item.itemName] = (
                    count: existing.count + item.quantity,
                    revenue: (existing.revenue + (Double(item.quantity) * item.unitPrice)).rounded(toPlaces: 2),
                    id: existing.id
                )
            }
        }
        
        let sortedItems = itemQuantities.sorted { $0.value.count > $1.value.count }
        let topSellingDishes = sortedItems.prefix(5).map { name, val in
            TopSellingDishDTO(
                id: val.id,
                name: name,
                categoryName: "Menu Item",
                quantitySold: val.count,
                revenue: val.revenue
            )
        }
        
        // Count 86'd items
        let eightySixedCount = try await FoodItem.query(on: req.db)
            .filter(\.$isAvailable == false)
            .count()
        
        let isRush = await BistroStateManager.shared.isRushHour
        
        return ZReportResponse(
            generatedAt: Date(),
            grossSales: grossSales,
            netSales: netSales,
            taxCollected: taxCollected,
            totalOrders: totalOrdersCount,
            averageTicketSize: avgTicket,
            activeKitchenTickets: activeTickets,
            dineInOrdersCount: dineInCount,
            pickupOrdersCount: pickupCount,
            deliveryOrdersCount: deliveryCount,
            isRushHour: isRush,
            topSellingDishes: topSellingDishes,
            eightySixedItemCount: eightySixedCount
        )
    }
}
