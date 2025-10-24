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

    private var results: [GameSearchItem] = []
    private var storesMap: [String: Store] = [:]                 // storeID -> Store
    private var detailCache: [String: (storeID: String?, oldPrice: String?)] = [:] // gameID -> tuple

    init(view: SearchViewProtocol, interactor: SearchInteractorProtocol) {
        self.view = view
        self.interactor = interactor
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
                let items = try await interactor.search(title: query)
                self.results = items
                self.detailCache.removeAll(keepingCapacity: true)
                self.view?.showResults(items)
            } catch {
                self.view?.showError("Arama başarısız: \(error.localizedDescription)")
            }
            self.view?.showLoading(false)
        }
    }

    func addToWatchlist(index: Int) {
        guard results.indices.contains(index) else { return }
        let item = results[index]
        let w = WatchItem(gameID: item.gameID, title: item.external, lastKnownPrice: Double(item.cheapest))
        WatchlistStore.shared.add(w)
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
}
