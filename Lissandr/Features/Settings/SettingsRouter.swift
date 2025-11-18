//
//  SettingsRouter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit

final class SettingsRouter: SettingsRouterProtocol {
    static func createModule() -> UIViewController {
        let vc = SettingsViewController()
        let interactor = SettingsInteractor()
        let presenter = SettingsPresenter(view: vc, interactor: interactor)
        vc.presenter = presenter
        return vc
    }
}
