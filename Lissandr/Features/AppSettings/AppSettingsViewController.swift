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
            case .notifications: return "Bildirimler"
            case .priceAlerts: return "Fiyat Alarmları"
            case .about: return "Hakkında"
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
        view.backgroundColor = .systemBackground
        title = "Ayarlar"
        
        // Extended layout
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(SwitchCell.self, forCellReuseIdentifier: "SwitchCell")
        
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
            return "Fiyat düşüşleri ve alarmlar için bildirim alın"
        case .priceAlerts:
            return "Oyunlar için özel fiyat alarmları kurun"
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
                cell.configure(title: "Bildirimleri Aç", isOn: UserDefaults.standard.bool(forKey: "notifications_enabled"))
                cell.onToggle = { isOn in
                    UserDefaults.standard.set(isOn, forKey: "notifications_enabled")
                    if isOn {
                        self.requestNotificationPermission()
                    }
                }
                return cell
            } else {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
                cell.textLabel?.text = "Arka Plan Yenileme"
                cell.detailTextLabel?.text = "Saatte bir"
                cell.accessoryType = .none
                cell.selectionStyle = .none
                return cell
            }
            
        case .priceAlerts:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = "Fiyat Alarmlarını Yönet"
            let alertCount = PriceAlertStore.shared.getActiveAlerts().count
            cell.detailTextLabel?.text = "\(alertCount) aktif"
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case .about:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.selectionStyle = indexPath.row == 2 ? .default : .none
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Versiyon"
                let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
                cell.detailTextLabel?.text = "\(version) (\(build))"
                cell.accessoryType = .none
            case 1:
                cell.textLabel?.text = "Geliştirici"
                cell.detailTextLabel?.text = "Umut Konmuş"
                cell.accessoryType = .none
            case 2:
                cell.textLabel?.text = "GitHub"
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
                    self.showToast(message: "Bildirimler açıldı")
                } else {
                    self.showToast(message: "Bildirim izni reddedildi")
                    UserDefaults.standard.set(false, forKey: "notifications_enabled")
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - SwitchCell

final class SwitchCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        contentView.addSubview(toggleSwitch)
        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        toggleSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func switchToggled() {
        onToggle?(toggleSwitch.isOn)
    }
    
    func configure(title: String, isOn: Bool) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }
}
