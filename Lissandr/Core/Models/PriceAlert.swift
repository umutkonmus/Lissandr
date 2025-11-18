//
//  PriceAlert.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

struct PriceAlert: Codable, Hashable {
    let id: UUID
    let gameID: String
    let gameTitle: String
    let targetPrice: Double
    let currentPrice: Double?
    var isActive: Bool
    let createdAt: Date
    
    init(gameID: String, gameTitle: String, targetPrice: Double, currentPrice: Double? = nil) {
        self.id = UUID()
        self.gameID = gameID
        self.gameTitle = gameTitle
        self.targetPrice = targetPrice
        self.currentPrice = currentPrice
        self.isActive = true
        self.createdAt = Date()
    }
}
