//
//  SplashInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class SplashInteractor: SplashInteractorProtocol {
    func initialLoad() async throws -> ([DealSummary], [Store]) {
        async let deals: [DealSummary] = HTTPClient.shared.request(CheapSharkEndpoint(.deals(pageSize: 40)), as: [DealSummary].self)
        async let stores: [Store] = HTTPClient.shared.request(CheapSharkEndpoint(.stores), as: [Store].self)
        return try await (deals, stores)
    }
}
