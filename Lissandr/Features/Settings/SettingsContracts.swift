//
//  SettingsContracts.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit

protocol SettingsViewProtocol: AnyObject {
    func displayAlerts(_ alerts: [PriceAlert])
    func showLoading(_ loading: Bool)
    func showError(_ message: String)
    func showToast(message: String)
}

protocol SettingsPresenterProtocol: AnyObject {
    func viewDidLoad()
    func refresh()
    func deleteAlert(at index: Int)
    func toggleAlert(at index: Int)
}

protocol SettingsInteractorProtocol: AnyObject {
    func loadAlerts() -> [PriceAlert]
    func removeAlert(id: UUID)
    func updateAlert(_ alert: PriceAlert)
}

protocol SettingsRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
}
