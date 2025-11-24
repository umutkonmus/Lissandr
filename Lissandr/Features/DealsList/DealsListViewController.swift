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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        // TableView'ın tab bar altına girmesini sağla
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // Large title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Oyun Fırsatları"
        
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
        
        presenter.viewDidLoad()
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
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func showLoading(_ loading: Bool) { DispatchQueue.main.async { loading ? self.activity.startAnimating() : self.activity.stopAnimating() } }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Tamam", style: .default))
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
