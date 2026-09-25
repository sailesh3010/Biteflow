import Fluent

struct CreateCategory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .field("icon", .string, .required)
            .field("sort_order", .int, .required)
            .unique(on: "name")
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("categories").delete()
    }
}
