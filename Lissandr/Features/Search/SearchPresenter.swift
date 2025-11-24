//
//  SearchPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation

final class SearchPresenter: SearchPresenterProtocol {
    weak var view: SearchViewProtocol?
    let interactor: SearchInteractorProtocol
    let router: SearchRouterProtocol

    private var results: [GameSearchItem] = []
    private var storesMap: [String: Store] = [:]                 // storeID -> Store
    private var detailCache: [String: (storeID: String?, oldPrice: String?)] = [:] // gameID -> tuple

    init(view: SearchViewProtocol, interactor: SearchInteractorProtocol, router: SearchRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    let gameAbbreviations: [String: String] = [
        "GTA": "Grand Theft Auto",
        "COD": "Call of Duty",
        "BF": "Battlefield",
        "AC": "Assassin’s Creed",
        "LOL": "League of Legends",
        "WoW": "World of Warcraft",
        "CS": "Counter-Strike",
        "CS:GO": "Counter-Strike: Global Offensive",
        "TES": "The Elder Scrolls",
        "FO": "Fallout",
        "MK": "Mortal Kombat",
        "RE": "Resident Evil",
        "FFX": "Final Fantasy X",
        "FFVII": "Final Fantasy VII",
        "KH": "Kingdom Hearts",
        "MH": "Monster Hunter",
        "OW": "Overwatch",
        "DMC": "Devil May Cry",
        "RDR": "Red Dead Redemption",
        "MHWI": "Monster Hunter World: Iceborne",
        "ACNH": "Animal Crossing: New Horizons",
        "BOTW": "Breath of the Wild",
        "SMO": "Super Mario Odyssey",
        "MK8": "Mario Kart 8",
        "DBZ": "Dragon Ball Z"
    ]

    func fullGameName(for input: String) -> String {
        // Büyük/küçük harf duyarsız arama
        if let fullName = gameAbbreviations[input.uppercased()] {
            return fullName
        } else {
            // Eğer kısaltma değilse zaten tam ad girilmiş
            return input
        }
    }

    func submit(query: String) {
        Task { [weak self] in
            guard let self else { return }
            self.view?.showLoading(true)
            do {
                if self.storesMap.isEmpty {
                    let stores = try await interactor.fetchStores()
                    self.storesMap = Dictionary(uniqueKeysWithValues: stores.map { ($0.storeID, $0) })
                }
                let items = try await interactor.search(title: fullGameName(for: query))
                self.results = items
                self.detailCache.removeAll(keepingCapacity: true)
                self.view?.showResults(items)
            } catch {
                self.view?.showError("search.error".localized(with: error.localizedDescription))
            }
            self.view?.showLoading(false)
        }
    }
    
    func didTapGame(index: Int) {
        guard results.indices.contains(index) else { return }
        let game = results[index]
        
        router.routeToGameDetail(gameID: game.gameID, title: game.external, thumb: game.thumb)
    }

    func addToWatchlist(index: Int) {
        guard results.indices.contains(index) else { return }
        let item = results[index]
        
        let normalized = item.cheapest.replacingOccurrences(of: ",", with: ".")
        let lastKnown = Double(normalized)

        let watch = WatchItem(gameID: item.gameID, title: item.external, lastKnownPrice: lastKnown)
        WatchlistStore.shared.add(watch)
        self.view?.showToast(message: "deals.addedToWatchlist".localized(with: item.external))
    }

    func displayInfo(for index: Int) -> (storeName: String?, oldPrice: String?) {
        guard results.indices.contains(index) else { return (nil, nil) }
        let gid = results[index].gameID
        let tuple = detailCache[gid]
        let name = tuple?.storeID.flatMap { storesMap[$0]?.storeName }
        return (name, tuple?.oldPrice)
    }

    func requestDetail(for index: Int) {
        guard results.indices.contains(index) else { return }
        let gid = results[index].gameID
        if detailCache[gid] != nil { return } // already fetched
        Task { [weak self] in
            guard let self else { return }
            do {
                let tuple = try await interactor.fetchDetail(gameID: gid)
                self.detailCache[gid] = tuple
                let storeName = tuple.storeID.flatMap { self.storesMap[$0]?.storeName }
                self.view?.updateRow(at: index, storeName: storeName, oldPrice: tuple.oldPrice)
            } catch {
                self.view?.updateRow(at: index, storeName: nil, oldPrice: nil)
            }
        }
    }
    
    func getGameID(at index: Int) -> String? {
        guard results.indices.contains(index) else { return nil }
        return results[index].gameID
    }
}
