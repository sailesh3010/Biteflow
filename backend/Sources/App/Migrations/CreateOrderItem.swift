import Fluent

struct CreateOrderItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("order_items")
            .id()
            .field("order_id", .uuid, .required,
                   .references("orders", "id", onDelete: .cascade))
            .field("food_item_id", .uuid, .required,
                   .references("food_items", "id", onDelete: .cascade))
            .field("quantity", .int, .required)
            .field("unit_price", .double, .required)
            .field("item_name", .string, .required)
            .field("special_notes", .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("order_items").delete()
    }
}
