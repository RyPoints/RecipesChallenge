import Foundation

protocol NetworkSession {
    func fetchData(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {
    func fetchData(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url)
    }
} 