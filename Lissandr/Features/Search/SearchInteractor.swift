//
//  SearchInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

final class SearchInteractor: SearchInteractorProtocol {
    func search(title: String) async throws -> [GameSearchItem] {
        try await HTTPClient.shared.request(CheapSharkEndpoint(.search(title: title)), as: [GameSearchItem].self)
    }
    func fetchStores() async throws -> [Store] {
        try await HTTPClient.shared.request(CheapSharkEndpoint(.stores), as: [Store].self)
    }
    func fetchDetail(gameID: String) async throws -> (storeID: String?, oldPrice: String?) {
        let detail = try await HTTPClient.shared.request(CheapSharkEndpoint(.game(id: gameID)), as: GameDetailResponse.self)
        guard let deals = detail.deals, !deals.isEmpty else { return (nil, nil) }
        // Choose the lowest price deal
        let best = deals.min { (a, b) in
            (Double(a.price) ?? .greatestFiniteMagnitude) < (Double(b.price) ?? .greatestFiniteMagnitude)
        }
        return (best?.storeID, best?.retailPrice)
    }
}
