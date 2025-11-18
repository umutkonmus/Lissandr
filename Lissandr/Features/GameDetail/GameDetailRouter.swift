//
//  GameDetailRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit

final class GameDetailRouter: GameDetailRouterProtocol {
    static func createModule(gameID: String, title: String, thumb: String) -> UIViewController {
        let vc = GameDetailViewController()
        let interactor = GameDetailInteractor()
        let router = GameDetailRouter()
        let presenter = GameDetailPresenter(
            view: vc,
            interactor: interactor,
            router: router,
            gameID: gameID,
            title: title,
            thumb: thumb
        )
        vc.presenter = presenter
        return vc
    }
}
