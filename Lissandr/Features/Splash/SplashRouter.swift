//
//  SplashRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class SplashRouter: SplashRouterProtocol {
    static func createModule() -> UIViewController {
        let vc = SplashViewController()
        let interactor = SplashInteractor()
        let router = SplashRouter()
        let presenter = SplashPresenter(view: vc, interactor: interactor, router: router)
        vc.presenter = presenter
        return vc
    }

    func routeToDeals(with deals: [DealSummary], stores: [String : Store], from: UIViewController) {
        let tabBar = RootTabBarController()

        if let nav = tabBar.viewControllers?.first as? UINavigationController,
           let dealsVC = nav.viewControllers.first as? DealsListViewController,
           let presenter = dealsVC.presenter as? DealsListPresenter {
            presenter.setInitialData(deals: deals, stores: stores)
        }
        
        if let window = from.view.window {
            window.rootViewController = tabBar
            UIView.transition(with: window,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: nil)
        }
        
        /*
        let dealsVC = DealsListRouter.createModule()
        if let p = (dealsVC as? DealsListViewController)?.presenter as? DealsListPresenter {
            p.setInitialData(deals: deals, stores: stores)
        }
        let nav = UINavigationController(rootViewController: dealsVC)
        from.view.window?.rootViewController = nav
         */
    }
}
