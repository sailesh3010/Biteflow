import Foundation

/// Centralized API client using native URLSession with async/await
final class APIService {
    
    static let shared = APIService()
    
    // MARK: - Configuration
    // Change this to your machine's local IP when testing from a physical device,
    // or use localhost for simulator testing.
    private let baseURL = "http://localhost:8080/api/v1"
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }
    
    // MARK: - Categories
    
    /// Fetch all categories (without items)
    func fetchCategories() async throws -> [CategoryResponse] {
        return try await get(path: "/categories")
    }
    
    /// Fetch all categories with their food items
    func fetchCategoriesWithItems() async throws -> [CategoryResponse] {
        return try await get(path: "/categories/with-items")
    }
    
    /// Fetch a single category with its items
    func fetchCategory(id: UUID) async throws -> CategoryResponse {
        return try await get(path: "/categories/\(id.uuidString)")
    }
    
    // MARK: - Food Items
    
    /// Fetch all available food items
    func fetchAllItems() async throws -> [FoodItemResponse] {
        return try await get(path: "/items")
    }
    
    /// Fetch featured (top-rated) items
    func fetchFeaturedItems() async throws -> [FoodItemResponse] {
        return try await get(path: "/items/featured")
    }
    
    /// Search items by name or description
    func searchItems(query: String) async throws -> [FoodItemResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await get(path: "/items/search?q=\(encodedQuery)")
    }
    
    /// Fetch a single food item
    func fetchItem(id: UUID) async throws -> FoodItemResponse {
        return try await get(path: "/items/\(id.uuidString)")
    }
    
    // MARK: - Orders
    
    /// Place a new order
    func placeOrder(request: CreateOrderRequest) async throws -> OrderResponse {
        return try await post(path: "/orders", body: request)
    }
    
    /// Fetch all orders
    func fetchOrders() async throws -> [OrderResponse] {
        return try await get(path: "/orders")
    }
    
    /// Fetch a single order with items
    func fetchOrder(id: UUID) async throws -> OrderResponse {
        return try await get(path: "/orders/\(id.uuidString)")
    }
    
    // MARK: - Generic HTTP Methods
    
    private func get<T: Decodable>(path: String) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        return try decoder.decode(T.self, from: data)
    }
    
    private func post<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        return try decoder.decode(T.self, from: data)
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400:
            throw APIError.badRequest
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError(httpResponse.statusCode)
        default:
            throw APIError.unexpectedStatus(httpResponse.statusCode)
        }
    }
}

// MARK: - Error Types

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case badRequest
    case notFound
    case serverError(Int)
    case unexpectedStatus(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .badRequest:
            return "Bad request — please check your input"
        case .notFound:
            return "The requested resource was not found"
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .unexpectedStatus(let code):
            return "Unexpected response (\(code))"
        }
    }
}
