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
            
            // Minimum splash animation süresi (0.3 saniye - daha da hızlı!)
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            // Hızlıca ana ekrana geç (boş data ile)
            await MainActor.run {
                self.router.routeToDeals(with: [], stores: [:], from: view)
            }
            
            // Arka planda verileri yükle
            do {
                let (deals, storesArr) = try await interactor.initialLoad()
                let storesMap = Dictionary(uniqueKeysWithValues: storesArr.map { ($0.storeID, $0) })
                
                // Ana ekrandaki presenter'ı güncelle
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .dealsDidLoad,
                        object: nil,
                        userInfo: ["deals": deals, "stores": storesMap]
                    )
                }
            } catch {
                // Hata durumunda kullanıcıya toast göster
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .dealsLoadFailed,
                        object: nil,
                        userInfo: ["error": error.localizedDescription]
                    )
                }
            }
        }
    }
}

// Notification isimleri
extension Notification.Name {
    static let dealsDidLoad = Notification.Name("dealsDidLoad")
    static let dealsLoadFailed = Notification.Name("dealsLoadFailed")
}
