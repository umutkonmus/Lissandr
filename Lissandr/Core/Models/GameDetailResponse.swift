//
//  GameDetailResponse.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

struct GameDetailResponse: Decodable {
    struct Info: Decodable {
        let title: String
        let thumb: String
    }
    struct CheapestPriceEver: Decodable {
        let price: String
        let date: Int
    }
    struct Deal: Decodable {
        let price: String
        let retailPrice: String
        let dealID: String
        let storeID: String
    }
    let info: Info
    let cheapestPriceEver: CheapestPriceEver
    let deals: [Deal]?
}
