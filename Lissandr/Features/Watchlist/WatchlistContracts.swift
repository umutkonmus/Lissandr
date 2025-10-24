//
//  WatchListContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

protocol WatchlistViewProtocol: AnyObject {
    func show(items: [WatchItem])
    func updatePrice(for gameID: String, current: Double?)
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
}

protocol WatchlistPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refresh()
    func delete(at index: Int)
}

protocol WatchlistInteractorProtocol: AnyObject {
    func loadWatchlist() -> [WatchItem]
    func remove(gameID: String)
    func fetchCurrentPrice(gameID: String) async throws -> Double?
}

protocol WatchlistRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
