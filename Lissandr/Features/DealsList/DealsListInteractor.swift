//
//  DealsListInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class DealsListInteractor: DealsListInteractorProtocol {
    func fetchDeals() async throws -> [DealSummary] {
        try await HTTPClient.shared.request(CheapSharkEndpoint(.deals(pageSize: 40)), as: [DealSummary].self)
    }
    func fetchStores() async throws -> [Store] {
        try await HTTPClient.shared.request(CheapSharkEndpoint(.stores), as: [Store].self)
    }
}
