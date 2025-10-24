//
//  SearchInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class SearchInteractor: SearchInteractorProtocol {
    func search(title: String) async throws -> [GameSearchItem] {
        try await HTTPClient.shared.request(CheapSharkEndpoint(.search(title: title)), as: [GameSearchItem].self)
    }
}
