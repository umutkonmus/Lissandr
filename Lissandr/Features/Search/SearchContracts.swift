//
//  SearchContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

protocol SearchViewProtocol: AnyObject {
    func showResults(_ items: [GameSearchItem])
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
    func updateRow(at index: Int, storeName: String?, oldPrice: String?)
    func showToast(message: String)
}

protocol SearchPresenterProtocol: AnyObject {
    func submit(query: String)
    func addToWatchlist(index: Int)
    func requestDetail(for index: Int)
    func displayInfo(for index: Int) -> (storeName: String?, oldPrice: String?)
}

protocol SearchInteractorProtocol: AnyObject {
    func search(title: String) async throws -> [GameSearchItem]
    func fetchStores() async throws -> [Store]
    /// Returns best (lowest price) deal's storeID and retail (old) price
    func fetchDetail(gameID: String) async throws -> (storeID: String?, oldPrice: String?)
}

protocol SearchRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
