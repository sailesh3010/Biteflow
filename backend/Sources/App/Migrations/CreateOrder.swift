import Fluent

struct CreateOrder: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("orders")
            .id()
            .field("customer_name", .string, .required)
            .field("customer_phone", .string, .required)
            .field("delivery_address", .string, .required)
            .field("subtotal", .double, .required)
            .field("tax", .double, .required)
            .field("delivery_fee", .double, .required)
            .field("total", .double, .required)
            .field("special_instructions", .string, .required)
            .field("dining_option", .string, .required)
            .field("table_number", .string)
            .field("split_count", .int, .required)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("orders").delete()
    }
}
