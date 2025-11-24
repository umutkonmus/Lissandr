//
//  DealsListViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit

final class DealsListViewController: UIViewController, DealsListViewProtocol, UITableViewDataSource, UITableViewDelegate {
    var presenter: DealsListPresenterProtocol!
    
    private var deals: [DealSummary] = []
    private var stores: [String: Store] = [:]
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activity = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    // Empty state view
    private lazy var emptyStateView: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        
        let iconView = UIImageView(image: UIImage(systemName: "magnifyingglass.circle.fill"))
        iconView.tintColor = .systemGray3
        iconView.contentMode = .scaleAspectFit
        iconView.snp.makeConstraints { $0.width.height.equalTo(80) }
        
        let label = UILabel()
        label.text = "Fırsatlar yükleniyor..."
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        
        let activitySmall = UIActivityIndicatorView(style: .medium)
        activitySmall.startAnimating()
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(activitySmall)
        
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        
        return container
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        // TableView'ın tab bar altına girmesini sağla
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // Large title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = String(localized: "deals.title", comment: "Deals screen title")
        
        // TableView setup
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DealsListCell.self, forCellReuseIdentifier: DealsListCell.reuse)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.contentInsetAdjustmentBehavior = .automatic
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        
        // Pull to refresh
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
        
        // Notification listener'ları ekle
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsLoaded),
            name: .dealsDidLoad,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDealsLoadFailed),
            name: .dealsLoadFailed,
            object: nil
        )
        
        presenter.viewDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleDealsLoaded(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let deals = userInfo["deals"] as? [DealSummary],
              let stores = userInfo["stores"] as? [String: Store] else { return }
        
        if let presenter = presenter as? DealsListPresenter {
            presenter.setInitialData(deals: deals, stores: stores)
        }
        
        // Refresh the view
        display(deals: deals, stores: stores)
        showLoading(false)
    }
    
    @objc private func handleDealsLoadFailed(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let errorMessage = userInfo["error"] as? String else { return }
        
        showLoading(false)
        showToast(message: "Veriler yüklenemedi: \(errorMessage)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload to update bookmark icons
        tableView.reloadData()
    }
    
    @objc private func refreshData() {
        presenter.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    func display(deals: [DealSummary], stores: [String : Store]) {
        self.deals = deals
        self.stores = stores
        DispatchQueue.main.async { 
            // Empty state'i gizle
            self.emptyStateView.removeFromSuperview()
            
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func showLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            if loading {
                self.activity.startAnimating()
                // Eğer deal yoksa empty state göster
                if self.deals.isEmpty {
                    self.view.addSubview(self.emptyStateView)
                    self.emptyStateView.snp.makeConstraints { $0.edges.equalTo(self.tableView) }
                }
            } else {
                self.activity.stopAnimating()
            }
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(
                title: String(localized: "common.error", comment: "Error alert title"),
                message: message,
                preferredStyle: .alert
            )
            ac.addAction(UIAlertAction(
                title: String(localized: "common.ok", comment: "OK button"),
                style: .default
            ))
            self?.present(ac, animated: true)
        }
    }
    
    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { deals.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealsListCell.reuse, for: indexPath) as! DealsListCell
        let d = deals[indexPath.row]
        let storeName = stores[d.storeID]?.storeName ?? "Store #\(d.storeID)"
        // Note: We don't have gameID here, so bookmark icon won't update until we resolve dealID
        cell.configure(title: d.title, store: storeName, price: d.salePrice, oldPrice: d.normalPrice, thumbURL: d.thumb)
        cell.onAddToWatchlist = { [weak self] in 
            self?.presenter.didTapAddToWatchlist(indexPath.row)
        }
        return cell
    }
    
    func reloadRow(at index: Int) {
        guard deals.indices.contains(index) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didTapDeal(indexPath.row)
    }
}
