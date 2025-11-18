//
//  GameDetailInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

final class GameDetailInteractor: GameDetailInteractorProtocol {
    func fetchGameDetails(for gameID: String) async throws -> GameDetailResponse {
        try await HTTPClient.shared.request(
            CheapSharkEndpoint(.game(id: gameID)),
            as: GameDetailResponse.self
        )
    }
    
    func fetchStores() async throws -> [Store] {
        try await HTTPClient.shared.request(
            CheapSharkEndpoint(.stores),
            as: [Store].self
        )
    }
}
