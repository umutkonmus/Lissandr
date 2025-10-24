//
//  PriceDropService.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class PriceDropService {
    static let shared = PriceDropService()
    private init() {}
    
    func checkWatchlistForDrops() async {
        let items = WatchlistStore.shared.load()
        for item in items {
            do {
                let detail = try await HTTPClient.shared.request(CheapSharkEndpoint(.game(id: item.gameID)), as: GameDetailResponse.self)
                if let current = detail.deals?.compactMap({ Double($0.price) }).min() {
                    let old = item.lastKnownPrice
                    if old == nil || current < (old ?? .greatestFiniteMagnitude) {
                        NotificationManager.shared.notifyPriceDrop(title: detail.info.title, oldPrice: old, newPrice: current)
                        // Update stored price
                        var newItems = items
                        if let idx = newItems.firstIndex(where: { $0.gameID == item.gameID }) {
                            newItems[idx].lastKnownPrice = current
                            WatchlistStore.shared.save(newItems)
                        }
                    }
                }
            } catch {
                print("Price check error for \(item.gameID): \(error)")
            }
        }
    }
}
