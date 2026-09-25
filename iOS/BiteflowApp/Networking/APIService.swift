import Foundation

/// Centralized API client using native URLSession with async/await
final class APIService {
    
    static let shared = APIService()
    
    // MARK: - Configuration
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
    
    func fetchCategories() async throws -> [CategoryResponse] {
        return try await get(path: "/categories")
    }
    
    func fetchCategoriesWithItems() async throws -> [CategoryResponse] {
        return try await get(path: "/categories/with-items")
    }
    
    func fetchCategory(id: UUID) async throws -> CategoryResponse {
        return try await get(path: "/categories/\(id.uuidString)")
    }
    
    // MARK: - Food Items
    
    func fetchAllItems() async throws -> [FoodItemResponse] {
        return try await get(path: "/items")
    }
    
    func fetchFeaturedItems() async throws -> [FoodItemResponse] {
        return try await get(path: "/items/featured")
    }
    
    func searchItems(query: String) async throws -> [FoodItemResponse] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return try await get(path: "/items/search?q=\(encodedQuery)")
    }
    
    func fetchItem(id: UUID) async throws -> FoodItemResponse {
        return try await get(path: "/items/\(id.uuidString)")
    }
    
    /// Fetch complementary upsell recommendations (Desserts/Drinks/Pairings)
    func fetchItemUpsells(id: UUID) async throws -> [FoodItemResponse] {
        return try await get(path: "/items/\(id.uuidString)/upsells")
    }
    
    /// Toggle 86'd status (sold-out) for a dish
    func toggleItem86(id: UUID, isAvailable: Bool? = nil) async throws -> FoodItemResponse {
        let body = ToggleItem86Request(isAvailable: isAvailable, stockCount: nil)
        return try await patch(path: "/items/\(id.uuidString)/toggle-86", body: body)
    }
    
    // MARK: - Bistro Operations & Manager Portal
    
    /// Real-time kitchen load & rush hour status
    func fetchBistroStatus() async throws -> BistroStatusResponse {
        return try await get(path: "/bistro/status")
    }
    
    /// Manager toggle for peak rush hour mode
    func toggleRushMode(enabled: Bool, extraMinutes: Int = 15) async throws -> BistroStatusResponse {
        let body = ToggleRushModeRequest(enabled: enabled, extraMinutes: extraMinutes)
        return try await post(path: "/bistro/rush-mode", body: body)
    }
    
    /// Fetch manager shift Z-Report and sales analytics
    func fetchZReport() async throws -> ZReportResponse {
        return try await get(path: "/bistro/z-report")
    }
    
    // MARK: - Orders
    
    func placeOrder(request: CreateOrderRequest) async throws -> OrderResponse {
        return try await post(path: "/orders", body: request)
    }
    
    func fetchOrders() async throws -> [OrderResponse] {
        return try await get(path: "/orders")
    }
    
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
    
    private func patch<T: Decodable, B: Encodable>(path: String, body: B) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
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
