import XCTest
@testable import Recipes

final class RecipeTests: XCTestCase {
    func testRecipeDecoding() throws {
        let json = """
        {
            "cuisine": "Malaysian",
            "name": "Apam Balik",
            "photo_url_large": "https://example.com/large.jpg",
            "photo_url_small": "https://example.com/small.jpg",
            "source_url": "https://example.com/recipe",
            "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
            "youtube_url": "https://youtube.com/watch"
        }
        """
        
        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(Recipe.self, from: data)
        
        XCTAssertEqual(recipe.cuisine, "Malaysian")
        XCTAssertEqual(recipe.name, "Apam Balik")
        XCTAssertEqual(recipe.photo_url_large, "https://example.com/large.jpg")
        XCTAssertEqual(recipe.photo_url_small, "https://example.com/small.jpg")
        XCTAssertEqual(recipe.source_url, "https://example.com/recipe")
        XCTAssertEqual(recipe.uuid, "0c6ca6e7-e32a-4053-b824-1dbf749910d8")
        XCTAssertEqual(recipe.youtube_url, "https://youtube.com/watch")
    }
    
    func testRecipeDecodingWithMissingOptionals() throws {
        let json = """
        {
            "cuisine": "Malaysian",
            "name": "Apam Balik",
            "photo_url_large": "https://example.com/large.jpg",
            "photo_url_small": "https://example.com/small.jpg",
            "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8"
        }
        """
        
        let data = json.data(using: .utf8)!
        let recipe = try JSONDecoder().decode(Recipe.self, from: data)
        
        XCTAssertNil(recipe.source_url)
        XCTAssertNil(recipe.youtube_url)
    }
} 
