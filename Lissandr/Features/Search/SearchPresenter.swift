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
    
    init(view: SearchViewProtocol, interactor: SearchInteractorProtocol) { self.view = view; self.interactor = interactor }
    
    func submit(query: String) {
        Task { [weak self] in
            guard let self else { return }
            self.view?.showLoading(true)
            do {
                let items = try await interactor.search(title: query)
                self.results = items
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
}
