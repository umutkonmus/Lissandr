//
//  HTTPClient.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class HTTPClient {
    static let shared = HTTPClient()
    private init() {}
    
    private let baseURL = URL(string: "https://www.cheapshark.com/api/1.0")!
    
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)!
        if let cs = endpoint as? CheapSharkEndpoint, let raw = cs.percentEncodedQueryOverride {
            // For /deal: use raw query exactly as provided (no extra encoding)
            components.percentEncodedQuery = raw
        } else {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else { throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.cannotParseResponse)
        }

        guard (200..<300).contains(http.statusCode) else {
            print("❌ HTTP Error")
            print("URL:", url)
            print("Status Code:", http.statusCode)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response:", responseString.prefix(500))
            }
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding Error")
            print("URL:", url)
            print("Error:", error)
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response:", responseString.prefix(500))
            }
            throw error
        }
    }
}
