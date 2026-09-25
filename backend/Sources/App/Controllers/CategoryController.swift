import Vapor
import Fluent

struct CategoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("categories")
        
        // GET /api/v1/categories — list all categories (without items)
        categories.get(use: index)
        
        // GET /api/v1/categories/with-items — list all categories with their food items
        categories.get("with-items", use: indexWithItems)
        
        // GET /api/v1/categories/:id — single category with its items
        categories.get(":categoryID", use: show)
    }
    
    // MARK: - Handlers
    
    @Sendable
    func index(req: Request) async throws -> [Category] {
        try await Category.query(on: req.db)
            .sort(\.$sortOrder)
            .all()
    }
    
    @Sendable
    func indexWithItems(req: Request) async throws -> [CategoryWithItemsResponse] {
        let categories = try await Category.query(on: req.db)
            .with(\.$items)
            .sort(\.$sortOrder)
            .all()
        
        return categories.map { CategoryWithItemsResponse(from: $0) }
    }
    
    @Sendable
    func show(req: Request) async throws -> CategoryWithItemsResponse {
        guard let category = try await Category.find(
            req.parameters.get("categoryID"), on: req.db
        ) else {
            throw Abort(.notFound, reason: "Category not found")
        }
        
        try await category.$items.load(on: req.db)
        return CategoryWithItemsResponse(from: category)
    }
}
