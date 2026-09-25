import Fluent

struct CreateFoodItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("food_items")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("price", .double, .required)
            .field("image_url", .string, .required)
            .field("calories", .int, .required)
            .field("prep_time_minutes", .int, .required)
            .field("is_vegetarian", .bool, .required)
            .field("is_spicy", .bool, .required)
            .field("is_available", .bool, .required)
            .field("stock_count", .int)
            .field("pairing_name", .string)
            .field("pairing_price", .double)
            .field("rating", .double, .required)
            .field("category_id", .uuid, .required,
                   .references("categories", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("food_items").delete()
    }
}
