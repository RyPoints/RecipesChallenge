import Foundation

struct Recipe: Codable, Identifiable {
    let cuisine: String
    let name: String
    let photo_url_large: String
    let photo_url_small: String
    let source_url: String?
    let uuid: String
    let youtube_url: String?
    var id: String { uuid }
    // Additional fields from SQLite database
    var ingredients: Ingredients?
    var method: [String]?
    var nutrition: [String: String]?
}

struct Ingredients: Codable {
    var main: [String]
    var garnishes: [String] // Didn't end up using, some sources had it
}

struct RecipeResponse: Codable {
    var recipes: [Recipe]
} 
