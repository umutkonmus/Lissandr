//
//  GameDetailContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit

struct GameDetailData {
    let gameID: String
    let title: String
    let thumb: String
    var currentPrice: Double?
    var historicalLow: Double?
    var deals: [(storeName: String, dealID: String, price: Double, retailPrice: Double)]
}

protocol GameDetailViewProtocol: AnyObject {
    func displayGame(_ game: GameDetailData)
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
    func showToast(message: String)
    func showPriceAlertDialog(currentPrice: Double, gameTitle: String)
}

protocol GameDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapAddToWatchlist()
    func didTapSetPriceAlert()
}

protocol GameDetailInteractorProtocol: AnyObject {
    func fetchGameDetails(for gameID: String) async throws -> GameDetailResponse
    func fetchStores() async throws -> [Store]
}

protocol GameDetailRouterProtocol: AnyObject {
    static func createModule(gameID: String, title: String, thumb: String) -> UIViewController
}
