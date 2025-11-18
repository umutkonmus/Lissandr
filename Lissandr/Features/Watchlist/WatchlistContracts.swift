//
//  WatchListContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

protocol WatchlistViewProtocol: AnyObject {
    func show(items: [WatchItem])
    func updatePrice(for gameID: String, price: Double?)
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
    func updateThumb(for gameID: String, url: String?)
}

protocol WatchlistPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refresh()
    func delete(at index: Int)
    func didTapGame(at index: Int)
}

protocol WatchlistInteractorProtocol: AnyObject {
    func loadWatchlist() -> [WatchItem]
    func remove(gameID: String)
    func fetchCurrentDetail(gameID: String) async throws -> GameDetailResponse
}

protocol WatchlistRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func routeToGameDetail(gameID: String, title: String, thumb: String?)
    var viewController: UIViewController? { get set }
}
