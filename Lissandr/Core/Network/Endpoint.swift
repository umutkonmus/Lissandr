//
//  Endpoint.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
}

struct CheapSharkEndpoint: Endpoint {
    enum Kind {
        case deals(storeID: String? = nil, pageSize: Int = 30)
        case search(title: String, limit: Int = 60, exact: Bool = false)
        case game(id: String) // details + cheapest price ever
        case stores
    }
    private let kind: Kind
    init(_ kind: Kind) { self.kind = kind }

    var path: String {
        switch kind {
        case .deals: return "/deals"
        case .search: return "/games"
        case .game: return "/games"
        case .stores: return "/stores"
        }
    }

    var method: HTTPMethod { .GET }

    var queryItems: [URLQueryItem] {
        switch kind {
        case .deals(let storeID, let pageSize):
            var items: [URLQueryItem] = [URLQueryItem(name: "pageSize", value: String(pageSize))]
            if let s = storeID { items.append(URLQueryItem(name: "storeID", value: s)) }
            items.append(URLQueryItem(name: "sortBy", value: "Price"))
            return items
        case .search(let title, let limit, let exact):
            return [
                URLQueryItem(name: "title", value: title),
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "exact", value: exact ? "1" : "0")
            ]
        case .game(let id):
            return [URLQueryItem(name: "id", value: id)]
        case .stores:
            return []
        }
    }
}
