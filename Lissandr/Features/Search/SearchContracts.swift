//
//  SearchContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

protocol SearchViewProtocol: AnyObject {
    func showResults(_ items: [GameSearchItem])
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
}

protocol SearchPresenterProtocol: AnyObject {
    func submit(query: String)
    func addToWatchlist(index: Int)
}

protocol SearchInteractorProtocol: AnyObject { func search(title: String) async throws -> [GameSearchItem] }
protocol SearchRouterProtocol: AnyObject { static func createModule() -> UIViewController }
