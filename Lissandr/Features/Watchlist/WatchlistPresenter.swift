//
//  WatchlistPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

final class WatchlistPresenter: WatchlistPresenterProtocol {
    weak var view: WatchlistViewProtocol?
    let interactor: WatchlistInteractorProtocol
    init(view: WatchlistViewProtocol, interactor: WatchlistInteractorProtocol) { self.view = view; self.interactor = interactor }

    private var items: [WatchItem] = []

    func viewDidLoad() {
        items = interactor.loadWatchlist()
        Task { @MainActor in self.view?.show(items: self.items) }
        refresh() // first fetch
    }

    func refresh() {
        Task { [weak self] in
            guard let self else { return }
            self.view?.showLoading(true)
            let gameIDs = self.items.map { $0.gameID }
            for gid in gameIDs {
                do {
                    let current = try await interactor.fetchCurrentDetail(gameID: gid)
                    let price = current.deals?.compactMap { Double($0.price) }.min()
                    self.view?.updatePrice(for: gid, price: price)
                    self.view?.updateThumb(for: gid, url: current.info.thumb)
                } catch {
                    // silently ignore per-row errors
                }
            }
            self.view?.showLoading(false)
        }
    }

    func delete(at index: Int) {
        guard items.indices.contains(index) else { return }
        let gid = items[index].gameID
        interactor.remove(gameID: gid)
        items.remove(at: index)
        Task { @MainActor in self.view?.show(items: self.items) }
    }
}
