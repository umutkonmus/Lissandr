//
//  SearchRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class SearchRouter: SearchRouterProtocol {
    static func createModule() -> UIViewController {
        let vc = SearchViewController()
        let interactor = SearchInteractor()
        let presenter = SearchPresenter(view: vc, interactor: interactor)
        vc.presenter = presenter
        vc.title = "Ara"
        return vc
    }
}
