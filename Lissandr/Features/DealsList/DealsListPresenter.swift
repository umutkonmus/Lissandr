//
//  DealsListPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class DealsListPresenter: DealsListPresenterProtocol {
    weak var view: DealsListViewProtocol?
    let interactor: DealsListInteractorProtocol
    let router: DealsListRouterProtocol
    private var deals: [DealSummary] = []
    private var storesMap: [String: Store] = [:]
    
    init(view: DealsListViewProtocol, interactor: DealsListInteractorProtocol, router: DealsListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    // Preload from Splash
    func setInitialData(deals: [DealSummary], stores: [String: Store]) {
        self.deals = deals
        self.storesMap = stores
    }
    
    func viewDidLoad() {
        Task { [weak self] in
            guard let self else { return }
            self.view?.showLoading(true)
            do {
                if self.deals.isEmpty { // if not preloaded by Splash
                    async let deals = interactor.fetchDeals()
                    async let stores = interactor.fetchStores()
                    let (d, s) = try await (deals, stores)
                    self.deals = d
                    self.storesMap = Dictionary(uniqueKeysWithValues: s.map { ($0.storeID, $0) })
                }
                self.view?.display(deals: self.deals, stores: self.storesMap)
            } catch {
                self.view?.showError("Bir şeyler ters gitti: \(error.localizedDescription)")
            }
            self.view?.showLoading(false)
        }
    }
    
    func didTapDeal(_ index: Int) {
        guard deals.indices.contains(index) else { return }
        let d = deals[index]
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let gameID = try await interactor.resolveGameID(fromDealID: d.dealID)
                await MainActor.run {
                    self.router.routeToGameDetail(gameID: gameID, title: d.title, thumb: d.thumb)
                }
            } catch {
                await MainActor.run {
                    self.view?.showError("Oyun detayı açılamadı: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func didTapAddToWatchlist(_ index: Int) {
        guard deals.indices.contains(index) else { return }
        let d = deals[index]
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let gameID = try await interactor.resolveGameID(fromDealID: d.dealID)
                let item = WatchItem(gameID: gameID, title: d.title, lastKnownPrice: Double(d.salePrice))
                WatchlistStore.shared.add(item)
                await MainActor.run {
                    self.view?.showToast(message:"\(d.title) listeye eklendi")
                    self.view?.reloadRow(at: index)
                }
            } catch {
                await MainActor.run {
                    self.view?.showError("Listeye eklenemedi: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func getDealID(at index: Int) -> String? {
        guard deals.indices.contains(index) else { return nil }
        return deals[index].dealID
    }
}
