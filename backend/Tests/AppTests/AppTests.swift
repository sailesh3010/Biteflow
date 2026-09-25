@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testHealthCheck() async throws {
        let app = try await Application.make(.testing)
        defer { Task { try await app.asyncShutdown() } }
        try configure(app)
        
        try await app.test(.GET, "/") { res async in
            XCTAssertEqual(res.status, .ok)
            XCTAssertContains(res.body.string, "Biteflow")
        }
    }
}
