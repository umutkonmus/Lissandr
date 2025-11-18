//
//  WatchlistRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

final class WatchlistRouter: WatchlistRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let vc = WatchlistViewController()
        let interactor = WatchlistInteractor()
        let router = WatchlistRouter()
        let presenter = WatchlistPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        router.viewController = vc
        vc.title = "Takip Listem"
        return vc
    }
    
    func routeToGameDetail(gameID: String, title: String, thumb: String?) {
        let detail = GameDetailRouter.createModule(gameID: gameID, title: title, thumb: thumb ?? "")
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }
}
