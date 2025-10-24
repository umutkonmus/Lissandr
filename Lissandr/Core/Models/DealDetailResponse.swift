//
//  DealDetailResponse.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

struct DealDetailResponse: Decodable {
    struct GameInfo: Decodable {
        let gameID: String
    }
    let gameInfo: GameInfo
}
