//
//  SettingsInteractor.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

final class SettingsInteractor: SettingsInteractorProtocol {
    func loadAlerts() -> [PriceAlert] {
        return PriceAlertStore.shared.load()
    }
    
    func removeAlert(id: UUID) {
        PriceAlertStore.shared.remove(id: id)
    }
    
    func updateAlert(_ alert: PriceAlert) {
        PriceAlertStore.shared.update(alert)
    }
}
