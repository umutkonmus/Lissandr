//
//  DealsListRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class DealsListRouter: DealsListRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let vc = DealsListViewController()
        let interactor = DealsListInteractor()
        let router = DealsListRouter()
        let presenter = DealsListPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        router.viewController = vc
        vc.title = "Oyun Fırsatları"
        return vc
    }
    
    func routeToSearch() {
        let search = SearchRouter.createModule()
        viewController?.navigationController?.pushViewController(search, animated: true)
    }
    
    func routeToGameDetail(gameID: String, title: String, thumb: String) {
        let detail = GameDetailRouter.createModule(gameID: gameID, title: title, thumb: thumb)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }
}
