import Vapor
import Fluent

struct FoodItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let items = routes.grouped("items")
        
        // GET /api/v1/items — all available food items
        items.get(use: index)
        
        // GET /api/v1/items/featured — top-rated items (rating >= 4.7)
        items.get("featured", use: featured)
        
        // GET /api/v1/items/search?q=truffle — search by name/description
        items.get("search", use: search)
        
        // GET /api/v1/items/:id — single item detail
        items.get(":itemID", use: show)
    }
    
    // MARK: - Handlers
    
    @Sendable
    func index(req: Request) async throws -> [FoodItem] {
        try await FoodItem.query(on: req.db)
            .filter(\.$isAvailable == true)
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
            .filter(\.$isAvailable == true)
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
}
