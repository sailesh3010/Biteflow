import Vapor
import Fluent
import FluentSQLiteDriver

func configure(_ app: Application) throws {
    // MARK: - CORS Middleware (allow iOS app connections)
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .DELETE, .PATCH, .OPTIONS],
        allowedHeaders: [
            .accept, .authorization, .contentType, .origin,
            .xRequestedWith, .userAgent, .accessControlAllowOrigin
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)
    
    // MARK: - Database Configuration (SQLite for local dev)
    app.databases.use(.sqlite(.file("biteflow.sqlite")), as: .sqlite)
    
    // MARK: - Migrations
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateFoodItem())
    app.migrations.add(CreateOrder())
    app.migrations.add(CreateOrderItem())
    app.migrations.add(SeedData())
    
    try app.autoMigrate().wait()
    
    // MARK: - Routes
    try routes(app)
    
    // MARK: - Server Configuration
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = 8080
    
    app.logger.info("🍔 Biteflow Backend running on http://localhost:8080")
}
