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
}
