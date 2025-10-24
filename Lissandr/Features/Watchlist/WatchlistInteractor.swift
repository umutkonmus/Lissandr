//
//  WatchlistInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

final class WatchlistInteractor: WatchlistInteractorProtocol {
    func loadWatchlist() -> [WatchItem] { WatchlistStore.shared.load() }
    func remove(gameID: String) { WatchlistStore.shared.remove(gameID: gameID) }

    func fetchCurrentPrice(gameID: String) async throws -> Double? {
        // /games?id= returns GameDetailResponse with deals; pick min price
        let detail: GameDetailResponse = try await HTTPClient.shared.request(CheapSharkEndpoint(.game(id: gameID)), as: GameDetailResponse.self)
        return detail.deals?.compactMap { Double($0.price) }.min()
    }
}
