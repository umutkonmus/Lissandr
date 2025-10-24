//
//  WatchlistRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

final class WatchlistRouter: WatchlistRouterProtocol {
    static func createModule() -> UIViewController {
        let vc = WatchlistViewController()
        let interactor = WatchlistInteractor()
        let presenter = WatchlistPresenter(view: vc, interactor: interactor)
        vc.presenter = presenter
        vc.title = "Takip Listem"
        return vc
    }
}
