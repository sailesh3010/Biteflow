import Vapor
import Fluent

struct OrderController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let orders = routes.grouped("orders")
        
        // POST /api/v1/orders — place a new order
        orders.post(use: create)
        
        // GET /api/v1/orders — list all orders
        orders.get(use: index)
        
        // GET /api/v1/orders/:id — get order details with items
        orders.get(":orderID", use: show)
        
        // PATCH /api/v1/orders/:id/status — update order status
        orders.patch(":orderID", "status", use: updateStatus)
        
        // DELETE /api/v1/orders/:id — cancel/delete an order
        orders.delete(":orderID", use: cancel)
    }
    
    // MARK: - Handlers
    
    @Sendable
    func create(req: Request) async throws -> OrderResponse {
        let input = try req.content.decode(CreateOrderRequest.self)
        
        guard !input.items.isEmpty else {
            throw Abort(.badRequest, reason: "Order must contain at least one item")
        }
        
        // Calculate pricing
        var subtotal: Double = 0
        var resolvedItems: [(CreateOrderItemRequest, FoodItem)] = []
        
        for orderItem in input.items {
            guard let foodItem = try await FoodItem.find(orderItem.foodItemID, on: req.db) else {
                throw Abort(.notFound, reason: "Food item \(orderItem.foodItemID) not found")
            }
            guard foodItem.isAvailable else {
                throw Abort(.badRequest, reason: "\(foodItem.name) is currently unavailable")
            }
            subtotal += foodItem.price * Double(orderItem.quantity)
            resolvedItems.append((orderItem, foodItem))
        }
        
        let tax = (subtotal * 0.08).rounded(toPlaces: 2)      // 8% tax
        let diningOption = input.diningOption ?? "delivery"
        // Dine-in and pickup have zero delivery fee
        let deliveryFee = (diningOption == "dine_in" || diningOption == "pickup" || subtotal >= 30.0) ? 0.0 : 3.99
        let total = (subtotal + tax + deliveryFee).rounded(toPlaces: 2)
        let splitCount = max(input.splitCount ?? 1, 1)
        
        // Create the order
        let order = Order(
            customerName: input.customerName,
            customerPhone: input.customerPhone,
            deliveryAddress: input.deliveryAddress,
            subtotal: subtotal.rounded(toPlaces: 2),
            tax: tax,
            deliveryFee: deliveryFee,
            total: total,
            specialInstructions: input.specialInstructions,
            diningOption: diningOption,
            tableNumber: input.tableNumber,
            splitCount: splitCount,
            status: .placed
        )
        try await order.save(on: req.db)
        
        // Create order items & auto-decrement inventory count
        var itemResponses: [OrderItemResponse] = []
        for (itemInput, foodItem) in resolvedItems {
            let orderItem = OrderItem(
                orderID: order.id!,
                foodItemID: foodItem.id!,
                quantity: itemInput.quantity,
                unitPrice: foodItem.price,
                itemName: foodItem.name,
                specialNotes: itemInput.specialNotes
            )
            try await orderItem.save(on: req.db)
            itemResponses.append(OrderItemResponse(from: orderItem))
            
            // Auto-inventory decrement (Bistro feature)
            if let currentStock = foodItem.stockCount {
                let remaining = max(0, currentStock - itemInput.quantity)
                foodItem.stockCount = remaining
                if remaining == 0 {
                    foodItem.isAvailable = false // Auto 86 when sold out!
                }
                try await foodItem.save(on: req.db)
            }
        }
        
        return OrderResponse(from: order, items: itemResponses)
    }
    
    @Sendable
    func index(req: Request) async throws -> [OrderResponse] {
        let orders = try await Order.query(on: req.db)
            .with(\.$items)
            .sort(\.$createdAt, .descending)
            .all()
        
        return orders.map { order in
            OrderResponse(
                from: order,
                items: order.items.map { OrderItemResponse(from: $0) }
            )
        }
    }
    
    @Sendable
    func show(req: Request) async throws -> OrderResponse {
        guard let order = try await Order.find(
            req.parameters.get("orderID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Order not found")
        }
        
        try await order.$items.load(on: req.db)
        
        return OrderResponse(
            from: order,
            items: order.items.map { OrderItemResponse(from: $0) }
        )
    }
    
    @Sendable
    func updateStatus(req: Request) async throws -> OrderResponse {
        guard let order = try await Order.find(
            req.parameters.get("orderID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Order not found")
        }
        
        let input = try req.content.decode(UpdateOrderStatusRequest.self)
        
        guard let newStatus = OrderStatus(rawValue: input.status) else {
            let valid = OrderStatus.allCases.map(\.rawValue).joined(separator: ", ")
            throw Abort(.badRequest, reason: "Invalid status. Valid values: \(valid)")
        }
        
        order.status = newStatus
        try await order.save(on: req.db)
        try await order.$items.load(on: req.db)
        
        return OrderResponse(
            from: order,
            items: order.items.map { OrderItemResponse(from: $0) }
        )
    }
    
    @Sendable
    func cancel(req: Request) async throws -> HTTPStatus {
        guard let order = try await Order.find(
            req.parameters.get("orderID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Order not found")
        }
        
        order.status = .cancelled
        try await order.save(on: req.db)
        return .noContent
    }
}

// MARK: - Helpers

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
