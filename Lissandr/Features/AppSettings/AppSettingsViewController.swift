//
//  AppSettingsViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit
import SnapKit

final class AppSettingsViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private enum SettingsSection: Int, CaseIterable {
        case notifications
        case priceAlerts
        case about
        
        var title: String {
            switch self {
            case .notifications: return "settings.notifications".localized
            case .priceAlerts: return "settings.priceAlerts".localized
            case .about: return "settings.about".localized
            }
        }
    }
    
    private enum SettingsRow {
        case notificationToggle
        case backgroundRefresh
        case priceAlertsList
        case version
        case developer
        case github
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Alarm sayısını güncellemek için tabloyu yenile
        tableView.reloadData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        title = "settings.title".localized
        
        // Extended layout
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // Large title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LiquidGlassCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(LiquidGlassSwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

// MARK: - TableView DataSource & Delegate

extension AppSettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let settingsSection = SettingsSection(rawValue: section) else { return 0 }
        
        switch settingsSection {
        case .notifications: return 2
        case .priceAlerts: return 1
        case .about: return 3
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingsSection(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard let settingsSection = SettingsSection(rawValue: section) else { return nil }
        
        switch settingsSection {
        case .notifications:
            return "settings.notificationsFooter".localized
        case .priceAlerts:
            return "settings.priceAlertsFooter".localized
        case .about:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch section {
        case .notifications:
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! LiquidGlassSwitchCell
                cell.configure(title: "settings.enableNotifications".localized, isOn: UserDefaults.standard.bool(forKey: "notifications_enabled"))
                cell.onToggle = { isOn in
                    UserDefaults.standard.set(isOn, forKey: "notifications_enabled")
                    if isOn {
                        self.requestNotificationPermission()
                    }
                }
                return cell
            } else {
                let cell = LiquidGlassCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "settings.backgroundRefresh".localized
                cell.detailTextLabel?.text = "settings.hourly".localized
                cell.accessoryType = .none
                cell.selectionStyle = .none
                return cell
            }
            
        case .priceAlerts:
            let cell = LiquidGlassCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "settings.managePriceAlerts".localized
            let alertCount = PriceAlertStore.shared.getActiveAlerts().count
            cell.detailTextLabel?.text = "settings.activeAlerts".localized(with: alertCount)
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .about:
            let cell = LiquidGlassCell(style: .value1, reuseIdentifier: nil)
            cell.selectionStyle = indexPath.row == 2 ? .default : .none
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "settings.version".localized
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                cell.detailTextLabel?.text = "\(version) (\(build))"
                cell.accessoryType = .none
            case 1:
                cell.textLabel?.text = "settings.developer".localized
                cell.detailTextLabel?.text = "Umut Konmuş"
                cell.accessoryType = .none
            case 2:
                cell.textLabel?.text = "settings.github".localized
                cell.detailTextLabel?.text = "@umutkonmus"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .priceAlerts:
            let settingsVC = SettingsRouter.createModule()
            navigationController?.pushViewController(settingsVC, animated: true)
            
        case .about:
            if indexPath.row == 2 {
                // GitHub link
                if let url = URL(string: "https://github.com/umutkonmus") {
                    UIApplication.shared.open(url)
                }
            }
            
        default:
            break
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.showToast(message: "settings.notificationsEnabled".localized)
                } else {
                    self.showToast(message: "settings.notificationsDenied".localized)
                    UserDefaults.standard.set(false, forKey: "notifications_enabled")
                    self.tableView.reloadData()
                }
            }
        }
    }
}
