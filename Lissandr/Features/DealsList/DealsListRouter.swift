//
//  DealsListRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class DealsListRouter: DealsListRouterProtocol {
    static func createModule() -> UIViewController {
        let vc = DealsListViewController()
        let interactor = DealsListInteractor()
        let router = DealsListRouter()
        let presenter = DealsListPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        vc.title = "Oyun Fırsatları"
        return vc
    }
    
    func routeToSearch(from: UIViewController) {
        let search = SearchRouter.createModule()
        from.navigationController?.pushViewController(search, animated: true)
    }
}
