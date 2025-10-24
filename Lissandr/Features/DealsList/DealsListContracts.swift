//
//  DealsListContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

protocol DealsListViewProtocol: AnyObject {
    func display(deals: [DealSummary], stores: [String: Store])
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
}

protocol DealsListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapSearch()
    func didTapAddToWatchlist(_ index: Int)
    func setInitialData(deals: [DealSummary], stores: [String: Store])
}

protocol DealsListInteractorProtocol: AnyObject {
    func fetchDeals() async throws -> [DealSummary]
    func fetchStores() async throws -> [Store]
}

protocol DealsListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func routeToSearch(from: UIViewController)
}
