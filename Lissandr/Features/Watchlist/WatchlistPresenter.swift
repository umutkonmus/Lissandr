//
//  WatchlistPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

final class WatchlistPresenter: WatchlistPresenterProtocol {
    weak var view: WatchlistViewProtocol?
    let interactor: WatchlistInteractorProtocol
    let router: WatchlistRouterProtocol
    
    init(view: WatchlistViewProtocol, interactor: WatchlistInteractorProtocol, router: WatchlistRouterProtocol) { 
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    private var items: [WatchItem] = []
    private var thumbCache: [String: String] = [:] // gameID -> thumb URL

    func viewDidLoad() {
        items = interactor.loadWatchlist()
        refresh()
    }
    
    func reload() {
        items = interactor.loadWatchlist()
        Task { @MainActor in view?.show(items: items) }
    }

    func refresh() {
        reload()
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
                    // Cache thumb URL
                    self.thumbCache[gid] = current.info.thumb
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
        thumbCache.removeValue(forKey: gid)
        refresh()
    }
    
    func didTapGame(at index: Int) {
        guard items.indices.contains(index) else { return }
        let item = items[index]
        let thumb = thumbCache[item.gameID] ?? ""
        router.routeToGameDetail(gameID: item.gameID, title: item.title, thumb: thumb)
    }
}
