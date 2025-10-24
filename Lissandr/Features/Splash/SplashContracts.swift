//
//  SplashContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

protocol SplashViewProtocol: AnyObject {
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
}
protocol SplashPresenterProtocol: AnyObject { func viewDidAppear() }
protocol SplashInteractorProtocol: AnyObject {
    func initialLoad() async throws -> ([DealSummary], [Store])
}
protocol SplashRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func routeToDeals(with deals: [DealSummary], stores: [String: Store], from: UIViewController)
}
