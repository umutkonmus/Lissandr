//
//  GameDetailPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

final class GameDetailPresenter: GameDetailPresenterProtocol {
    weak var view: GameDetailViewProtocol?
    let interactor: GameDetailInteractorProtocol
    let router: GameDetailRouterProtocol
    
    private let gameID: String
    private let gameTitle: String
    private let gameThumb: String
    private var gameData: GameDetailData?
    private var storesMap: [String: Store] = [:]
    
    init(view: GameDetailViewProtocol, interactor: GameDetailInteractorProtocol, router: GameDetailRouterProtocol, gameID: String, title: String, thumb: String) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.gameID = gameID
        self.gameTitle = title
        self.gameThumb = thumb
    }
    
    func viewDidLoad() {
        loadData()
    }
    
    private func loadData() {
        Task { [weak self] in
            guard let self else { return }
            await MainActor.run { self.view?.showLoading(true) }
            
            do {
                // Fetch stores first
                let stores = try await interactor.fetchStores()
                self.storesMap = Dictionary(uniqueKeysWithValues: stores.map { ($0.storeID, $0) })
                
                // Fetch game details
                let detail = try await interactor.fetchGameDetails(for: self.gameID)
                
                let currentPrice = detail.deals?.compactMap({ Double($0.price) }).min()
                let historicalLow = Double(detail.cheapestPriceEver.price)
                
                var dealsList: [(String, String, Double, Double)] = []
                if let deals = detail.deals {
                    for deal in deals.prefix(10) { // Top 10 deals
                        if let price = Double(deal.price),
                           let retail = Double(deal.retailPrice) {
                            let storeName = self.storesMap[deal.storeID]?.storeName ?? "Store #\(deal.storeID)"
                            let dealID = deal.dealID
                            dealsList.append((storeName, dealID, price, retail))
                        }
                    }
                }
                
                let gameData = GameDetailData(
                    gameID: self.gameID,
                    title: self.gameTitle,
                    thumb: self.gameThumb,
                    currentPrice: currentPrice,
                    historicalLow: historicalLow,
                    deals: dealsList
                )
                
                self.gameData = gameData
                await MainActor.run {
                    self.view?.displayGame(gameData)
                    self.view?.showLoading(false)
                }
                
            } catch {
                await MainActor.run {
                    self.view?.showError("Veriler yüklenemedi: \(error.localizedDescription)")
                    self.view?.showLoading(false)
                }
            }
        }
    }
    
    func didTapAddToWatchlist() {
        guard let gameData = gameData else { return }
        
        let item = WatchItem(
            gameID: gameData.gameID,
            title: gameData.title,
            lastKnownPrice: gameData.currentPrice
        )
        WatchlistStore.shared.add(item)
        view?.showToast(message: "\(gameData.title) takip listesine eklendi")
    }
    
    func didTapSetPriceAlert() {
        guard let gameData = gameData else { return }
        view?.showPriceAlertDialog(currentPrice: gameData.currentPrice ?? 0, gameTitle: gameData.title)
    }
}
