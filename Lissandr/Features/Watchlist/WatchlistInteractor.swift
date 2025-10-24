//
//  WatchlistInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

final class WatchlistInteractor: WatchlistInteractorProtocol {
    func loadWatchlist() -> [WatchItem] { WatchlistStore.shared.load() }
    func remove(gameID: String) { WatchlistStore.shared.remove(gameID: gameID) }

    func fetchCurrentDetail(gameID: String) async throws -> GameDetailResponse {
        print(gameID)
        let detail: GameDetailResponse = try await HTTPClient.shared.request(CheapSharkEndpoint(.game(id: gameID)), as: GameDetailResponse.self)
        return detail
    }
}
