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
        // Check watchlist items
        let items = WatchlistStore.shared.load()
        for item in items {
            do {
                let detail: GameDetailResponse = try await HTTPClient.shared.request(
                    CheapSharkEndpoint(.game(id: item.gameID)), as: GameDetailResponse.self
                )
                if let current = detail.deals?.compactMap({ Double($0.price) }).min() {
                    let old = item.lastKnownPrice
                    if old == nil || current < (old ?? .greatestFiniteMagnitude) {
                        NotificationManager.shared.notifyPriceDrop(
                            title: detail.info.title, oldPrice: old, newPrice: current
                        )
                        // Kaydı güncelle
                        var newItems = items
                        if let idx = newItems.firstIndex(where: { $0.gameID == item.gameID }) {
                            newItems[idx].lastKnownPrice = current
                            WatchlistStore.shared.save(newItems)
                        }
                    }
                }
            } catch {
                print("Price check error: \(error)")
            }
        }
        
        // Check price alerts
        await checkPriceAlerts()
    }
    
    private func checkPriceAlerts() async {
        let alerts = PriceAlertStore.shared.getActiveAlerts()
        
        for alert in alerts {
            do {
                let detail: GameDetailResponse = try await HTTPClient.shared.request(
                    CheapSharkEndpoint(.game(id: alert.gameID)), as: GameDetailResponse.self
                )
                
                if let currentPrice = detail.deals?.compactMap({ Double($0.price) }).min() {
                    // Check if price dropped below target
                    if currentPrice <= alert.targetPrice {
                        NotificationManager.shared.notifyPriceAlert(
                            title: alert.gameTitle,
                            targetPrice: alert.targetPrice,
                            currentPrice: currentPrice
                        )
                        
                        // Deactivate alert after triggering
                        var updatedAlert = alert
                        updatedAlert.isActive = false
                        PriceAlertStore.shared.update(updatedAlert)
                    }
                }
            } catch {
                print("Price alert check error: \(error)")
            }
        }
    }
}
