//
//  SplashPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit

final class SplashPresenter: SplashPresenterProtocol {
    weak var view: SplashViewProtocol?
    let interactor: SplashInteractorProtocol
    let router: SplashRouterProtocol
    
    init(view: SplashViewProtocol, interactor: SplashInteractorProtocol, router: SplashRouterProtocol) {
        self.view = view; self.interactor = interactor; self.router = router
    }
    
    func viewDidAppear() {
        Task { [weak self] in
            guard let self, let view = self.view as? UIViewController else { return }
            self.view?.showLoading(true)
            do {
                let (deals, storesArr) = try await interactor.initialLoad()
                let storesMap = Dictionary(uniqueKeysWithValues: storesArr.map { ($0.storeID, $0) })
                self.router.routeToDeals(with: deals, stores: storesMap, from: view)
            } catch {
                self.view?.showError("Veriler alınamadı: \(error.localizedDescription)")
            }
            self.view?.showLoading(false)
        }
    }
}
