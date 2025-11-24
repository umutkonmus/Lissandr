//
//  SettingsViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit
import SnapKit

final class SettingsViewController: UIViewController, SettingsViewProtocol {
    var presenter: SettingsPresenterProtocol!
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activity = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()
    
    private var alerts: [PriceAlert] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.refresh()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Fiyat Alarmları"
        
        // Extended layout
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // TableView
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PriceAlertCell.self, forCellReuseIdentifier: "PriceAlertCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        // Empty state
        emptyLabel.text = "Henüz fiyat alarmı yok\n\nOyun detay sayfasından\nfiyat alarmı kurabilirsiniz"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .preferredFont(forTextStyle: .body)
        emptyLabel.isHidden = true
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.right.equalToSuperview().inset(32)
        }
        
        // Activity
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    // MARK: - View Protocol
    
    func displayAlerts(_ alerts: [PriceAlert]) {
        self.alerts = alerts
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.emptyLabel.isHidden = !alerts.isEmpty
            self.tableView.reloadData()
        }
    }
    
    func showLoading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            loading ? self?.activity.startAnimating() : self?.activity.stopAnimating()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self?.present(alert, animated: true)
        }
    }
}

// MARK: - TableView DataSource & Delegate

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return alerts.filter { $0.isActive }.count
        } else {
            return alerts.filter { !$0.isActive }.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return alerts.filter { $0.isActive }.isEmpty ? nil : "Aktif Alarmlar"
        } else {
            return alerts.filter { !$0.isActive }.isEmpty ? nil : "Pasif Alarmlar"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriceAlertCell", for: indexPath) as! PriceAlertCell
        
        let filteredAlerts = indexPath.section == 0 ? alerts.filter { $0.isActive } : alerts.filter { !$0.isActive }
        guard filteredAlerts.indices.contains(indexPath.row) else { return cell }
        
        let alert = filteredAlerts[indexPath.row]
        cell.configure(with: alert)
        cell.onToggle = { [weak self] in
            guard let self else { return }
            if let globalIndex = self.alerts.firstIndex(where: { $0.id == alert.id }) {
                self.presenter.toggleAlert(at: globalIndex)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let filteredAlerts = indexPath.section == 0 ? alerts.filter { $0.isActive } : alerts.filter { !$0.isActive }
        guard filteredAlerts.indices.contains(indexPath.row) else { return nil }
        
        let alert = filteredAlerts[indexPath.row]
        
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, done in
            guard let self else { return }
            if let globalIndex = self.alerts.firstIndex(where: { $0.id == alert.id }) {
                self.presenter.deleteAlert(at: globalIndex)
            }
            done(true)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
