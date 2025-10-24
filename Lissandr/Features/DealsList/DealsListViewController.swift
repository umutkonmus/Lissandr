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
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activity = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .search, primaryAction: UIAction(handler: { [weak self] _ in self?.presenter.didTapSearch() }))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Takip Listem",
            style: .plain,
            target: self,
            action: #selector(openWatchlist)
        )
        
        view.addSubview(tableView)
        tableView.dataSource = self; tableView.delegate = self
        tableView.register(DealsListCell.self, forCellReuseIdentifier: DealsListCell.reuse)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
        
        presenter.viewDidLoad()
    }
    
    @objc private func openWatchlist() {
        let vc = WatchlistRouter.createModule()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func display(deals: [DealSummary], stores: [String : Store]) {
        self.deals = deals
        self.stores = stores
        DispatchQueue.main.async { self.tableView.reloadData() }
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
        cell.configure(title: d.title, store: storeName, price: d.salePrice, oldPrice: d.normalPrice, thumbURL: d.thumb)
        cell.onAddToWatchlist = { [weak self] in self?.presenter.didTapAddToWatchlist(indexPath.row) }
        return cell
    }
}
