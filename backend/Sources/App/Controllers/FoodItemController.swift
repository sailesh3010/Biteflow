import Vapor
import Fluent

struct FoodItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let items = routes.grouped("items")
        
        // GET /api/v1/items — all food items (including 86'd status)
        items.get(use: index)
        
        // GET /api/v1/items/featured — top-rated items (rating >= 4.7)
        items.get("featured", use: featured)
        
        // GET /api/v1/items/search?q=truffle — search by name/description
        items.get("search", use: search)
        
        // GET /api/v1/items/:itemID — single item detail
        items.get(":itemID", use: show)
        
        // GET /api/v1/items/:itemID/upsells — complementary pairings/sides
        items.get(":itemID", "upsells", use: upsells)
        
        // PATCH /api/v1/items/:itemID/toggle-86 — instant 86/sold-out toggle
        items.patch(":itemID", "toggle-86", use: toggle86)
        
        // PATCH /api/v1/items/:itemID/stock — update stock count
        items.patch(":itemID", "stock", use: updateStock)
    }
    
    // MARK: - Handlers
    
    @Sendable
    func index(req: Request) async throws -> [FoodItem] {
        // Return all items with their category loaded
        try await FoodItem.query(on: req.db)
            .with(\.$category)
            .all()
    }
    
    @Sendable
    func featured(req: Request) async throws -> [FoodItem] {
        try await FoodItem.query(on: req.db)
            .filter(\.$isAvailable == true)
            .filter(\.$rating >= 4.7)
            .with(\.$category)
            .sort(\.$rating, .descending)
            .all()
    }
    
    @Sendable
    func search(req: Request) async throws -> [FoodItem] {
        guard let query = req.query[String.self, at: "q"],
              !query.isEmpty else {
            throw Abort(.badRequest, reason: "Search query 'q' is required")
        }
        
        return try await FoodItem.query(on: req.db)
            .group(.or) { group in
                group.filter(\.$name, .custom("LIKE"), "%\(query)%")
                group.filter(\.$description, .custom("LIKE"), "%\(query)%")
            }
            .with(\.$category)
            .all()
    }
    
    @Sendable
    func show(req: Request) async throws -> FoodItem {
        guard let item = try await FoodItem.find(
            req.parameters.get("itemID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Food item not found")
        }
        
        try await item.$category.load(on: req.db)
        return item
    }
    
    @Sendable
    func upsells(req: Request) async throws -> [FoodItem] {
        guard let item = try await FoodItem.find(
            req.parameters.get("itemID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Food item not found")
        }
        
        // Complementary upsells: dessert or drinks categories
        return try await FoodItem.query(on: req.db)
            .filter(\.$isAvailable == true)
            .filter(\.$id != item.id!)
            .with(\.$category)
            .limit(3)
            .all()
    }
    
    @Sendable
    func toggle86(req: Request) async throws -> FoodItem {
        guard let item = try await FoodItem.find(
            req.parameters.get("itemID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Food item not found")
        }
        
        // Flip availability or read optional payload
        if let body = try? req.content.decode(ToggleItem86Request.self), let overrideVal = body.isAvailable {
            item.isAvailable = overrideVal
        } else {
            item.isAvailable.toggle()
        }
        
        try await item.save(on: req.db)
        try await item.$category.load(on: req.db)
        return item
    }
    
    @Sendable
    func updateStock(req: Request) async throws -> FoodItem {
        guard let item = try await FoodItem.find(
            req.parameters.get("itemID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Food item not found")
        }
        
        let body = try req.content.decode(ToggleItem86Request.self)
        item.stockCount = body.stockCount
        if let count = body.stockCount, count <= 0 {
            item.isAvailable = false
        }
        
        try await item.save(on: req.db)
        try await item.$category.load(on: req.db)
        return item
    }
}
