//
//  SettingsPresenter.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import Foundation

final class SettingsPresenter: SettingsPresenterProtocol {
    weak var view: SettingsViewProtocol?
    let interactor: SettingsInteractorProtocol
    
    private var alerts: [PriceAlert] = []
    
    init(view: SettingsViewProtocol, interactor: SettingsInteractorProtocol) {
        self.view = view
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        refresh()
    }
    
    func refresh() {
        alerts = interactor.loadAlerts()
        view?.displayAlerts(alerts)
    }
    
    func deleteAlert(at index: Int) {
        guard alerts.indices.contains(index) else { return }
        let alert = alerts[index]
        interactor.removeAlert(id: alert.id)
        alerts.remove(at: index)
        view?.displayAlerts(alerts)
        view?.showToast(message: NSLocalizedString("alert.alarmDeleted", comment: ""))
    }
    
    func toggleAlert(at index: Int) {
        guard alerts.indices.contains(index) else { return }
        var alert = alerts[index]
        alert.isActive.toggle()
        interactor.updateAlert(alert)
        alerts[index] = alert
        view?.displayAlerts(alerts)
        
        let statusKey = alert.isActive ? "alert.alarmActivated" : "alert.alarmDeactivated"
        view?.showToast(message: NSLocalizedString(statusKey, comment: ""))
    }
}
