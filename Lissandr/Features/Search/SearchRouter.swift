//
//  SearchRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class SearchRouter: SearchRouterProtocol {
    weak var viewController: UIViewController?
    
    static func createModule() -> UIViewController {
        let vc = SearchViewController()
        let interactor = SearchInteractor()
        let router = SearchRouter()
        let presenter = SearchPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        router.viewController = vc
        vc.title = "Ara"
        return vc
    }
    
    func routeToGameDetail(gameID: String, title: String, thumb: String) {
        let detail = GameDetailRouter.createModule(gameID: gameID, title: title, thumb: thumb)
        viewController?.navigationController?.pushViewController(detail, animated: true)
    }
}
