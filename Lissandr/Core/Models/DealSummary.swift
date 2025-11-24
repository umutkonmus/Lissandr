//
//  Deal.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

struct DealSummary: Decodable {
    let dealID: String
    let title: String
    let salePrice: String
    let normalPrice: String
    let savings: String
    let thumb: String
    let storeID: String
    let steamAppID: String?
    let metacriticScore: String?
    let metacriticLink: String?
    let steamRatingText: String?
    let steamRatingPercent: String?
    let steamRatingCount: String?
}
