//
//  WatchItem.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

struct WatchItem: Codable, Hashable {
    let gameID: String
    var title: String
    var lastKnownPrice: Double?
    
    // Equatable implementation - sadece gameID'ye göre karşılaştır
    static func == (lhs: WatchItem, rhs: WatchItem) -> Bool {
        return lhs.gameID == rhs.gameID
    }
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(gameID)
    }
}
