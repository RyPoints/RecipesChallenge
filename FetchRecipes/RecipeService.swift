import Foundation
import SQLite3

class RecipeService {
    private let session: NetworkSession
    private let endpoint: String
    private var db: OpaquePointer?
    
    init(session: NetworkSession = URLSession.shared, endpoint: String = Endpoint.recipes) {
        self.session = session
        self.endpoint = endpoint
        
        // Open SQLite database from app directory
        if let bundleURL = Bundle.main.resourceURL {
            let dbPath = bundleURL.appendingPathComponent("recipes.db").path
            if sqlite3_open(dbPath, &db) != SQLITE_OK {
                print("Error opening database: \(String(cString: sqlite3_errmsg(db)))")
            } else {
                print("Successfully opened database at: \(dbPath)")
            }
        } else {
            print("Could not find app bundle directory")
        }
    }
    
    deinit {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    private func getRecipeDetails(for url: String) -> (ingredients: Ingredients?, method: [String]?, nutrition: [String: String]?) {
        var ingredients: Ingredients?
        var method: [String]?
        var nutrition: [String: String]?
        
        let queryString = "SELECT ingredients, method, nutrition FROM recipes WHERE url = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (url as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_ROW {
                // Get ingredients
                if let ingredientsData = sqlite3_column_text(statement, 0) {
                    let ingredientsString = String(cString: ingredientsData)
                    // print("Ingredients JSON: \(ingredientsString)")
                    if let data = ingredientsString.data(using: .utf8) {
                        ingredients = try? JSONDecoder().decode(Ingredients.self, from: data)
                    }
                }
                
                // Get method
                if let methodData = sqlite3_column_text(statement, 1) {
                    let methodString = String(cString: methodData)
                    // print("Method JSON: \(methodString)")
                    if let data = methodString.data(using: .utf8) {
                        method = try? JSONDecoder().decode([String].self, from: data)
                    }
                }
                
                // Get nutrition
                if let nutritionData = sqlite3_column_text(statement, 2) {
                    let nutritionString = String(cString: nutritionData)
                    // print("Nutrition JSON: \(nutritionString)")
                    if let data = nutritionString.data(using: .utf8) {
                        nutrition = try? JSONDecoder().decode([String: String].self, from: data)
                    }
                }
            } else {
                print("No recipe found in database for URL: \(url)")
            }
        } else {
            print("Failed to prepare statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        
        // Debug print the results
        // print("Retrieved from database for \(url):")
        // print("Ingredients: \(ingredients?.main.count ?? 0) main, \(ingredients?.garnishes.count ?? 0) garnishes")
        // print("Method steps: \(method?.count ?? 0)")
        // print("Nutrition items: \(nutrition?.count ?? 0)")
        
        return (ingredients, method, nutrition)
    }
    
    func fetchRecipes() async throws -> [Recipe] {
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await session.fetchData(from: url)
        let decoder = JSONDecoder()
        decoder.allowsJSON5 = true
        var response = try decoder.decode(RecipeResponse.self, from: data)
        
        // Supplement recipes with SQLite data
        response.recipes = response.recipes.map { recipe in
            var enhancedRecipe = recipe
            if let sourceUrl = recipe.source_url {
                let details = getRecipeDetails(for: sourceUrl)
                enhancedRecipe.ingredients = details.ingredients
                enhancedRecipe.method = details.method
                enhancedRecipe.nutrition = details.nutrition
            }
            return enhancedRecipe
        }
        
        return response.recipes
    }
} 
