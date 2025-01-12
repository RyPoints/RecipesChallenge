import XCTest
@testable import Recipes

// Mock NetworkSession implementation
class MockNetworkSession: NetworkSession {
    var data: Data?
    var error: Error?
    
    func fetchData(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return (data ?? Data(), response)
    }
}

final class RecipeServiceTests: XCTestCase {
    var mockSession: MockNetworkSession!
    var sut: RecipeService!
    
    override func setUp() {
        super.setUp()
        mockSession = MockNetworkSession()
        sut = RecipeService(session: mockSession, endpoint: "https://example.com/recipes")
    }
    
    override func tearDown() {
        mockSession = nil
        sut = nil
        super.tearDown()
    }
    
    func testSuccessfulFetch() async throws {
        // Given
        let json = """
        {
            "recipes": [
                {
                    "cuisine": "Malaysian",
                    "name": "Apam Balik",
                    "photo_url_large": "https://example.com/large.jpg",
                    "photo_url_small": "https://example.com/small.jpg",
                    "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
                }
            ]
        }
        """
        mockSession.data = json.data(using: .utf8)
        
        // When
        let recipes = try await sut.fetchRecipes()
        
        // Then
        XCTAssertEqual(recipes.count, 1)
        XCTAssertEqual(recipes.first?.name, "Apam Balik")
    }
    
    func testMalformedJSONFetch() async {
        // Given
        let json = """
        {
            "recipes": [
                {
                    "invalid": "data"
                }
            ]
        }
        """
        mockSession.data = json.data(using: .utf8)
        
        // When/Then
        do {
            _ = try await sut.fetchRecipes()
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertTrue(error is DecodingError)
        }
    }
    
    func testNetworkError() async {
        // Given
        mockSession.error = URLError(.notConnectedToInternet)
        
        // When/Then
        do {
            _ = try await sut.fetchRecipes()
            XCTFail("Expected network error")
        } catch {
            XCTAssertTrue(error is URLError)
        }
    }
} 
