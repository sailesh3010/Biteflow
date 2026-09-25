import Vapor

func routes(_ app: Application) throws {
    // Health check
    app.get { req async -> String in
        "🍔 Biteflow API is running!"
    }
    
    // API v1 route group
    let api = app.grouped("api", "v1")
    
    // Register controllers
    try api.register(collection: CategoryController())
    try api.register(collection: FoodItemController())
    try api.register(collection: OrderController())
    try api.register(collection: BistroController())
}
