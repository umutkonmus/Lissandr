//
//  PriceAlertStore.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

final class PriceAlertStore {
    static let shared = PriceAlertStore()
    private init() {}
    private let key = "price.alerts.v1"

    func load() -> [PriceAlert] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([PriceAlert].self, from: data)) ?? []
    }

    func save(_ alerts: [PriceAlert]) {
        if let data = try? JSONEncoder().encode(alerts) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func add(_ alert: PriceAlert) {
        var alerts = load()
        alerts.append(alert)
        save(alerts)
    }
    
    func hasActiveAlert(for gameID: String) -> PriceAlert? {
        return load().first { $0.gameID == gameID && $0.isActive }
    }
    
    func updateOrAdd(_ alert: PriceAlert) {
        var alerts = load()
        
        // Aynı oyun için aktif alarm varsa güncelle
        if let index = alerts.firstIndex(where: { $0.gameID == alert.gameID && $0.isActive }) {
            alerts[index] = alert
        } else {
            alerts.append(alert)
        }
        
        save(alerts)
    }

    func remove(id: UUID) {
        var alerts = load()
        alerts.removeAll { $0.id == id }
        save(alerts)
    }
    
    func update(_ alert: PriceAlert) {
        var alerts = load()
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index] = alert
            save(alerts)
        }
    }
    
    func getActiveAlerts() -> [PriceAlert] {
        return load().filter { $0.isActive }
    }
}
