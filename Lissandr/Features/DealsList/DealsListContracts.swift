//
//  DealsListContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

protocol DealsListViewProtocol: AnyObject {
    func display(deals: [DealSummary], stores: [String: Store])
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
    func showToast(message: String)
}

protocol DealsListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSearch()
    func didTapDeal(_ index: Int)
    func didTapAddToWatchlist(_ index: Int)
    func setInitialData(deals: [DealSummary], stores: [String: Store])
    func getDealID(at index: Int) -> String?
}

protocol DealsListInteractorProtocol: AnyObject {
    func fetchDeals() async throws -> [DealSummary]
    func fetchStores() async throws -> [Store]
    func resolveGameID(fromDealID dealID: String) async throws -> String 
}

protocol DealsListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func routeToSearch()
    func routeToGameDetail(gameID: String, title: String, thumb: String)
    var viewController: UIViewController? { get set }
}
