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
        view.backgroundColor = .systemBackground
        
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
            // Reload after a short delay to update icon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didTapDeal(indexPath.row)
    }
}

extension UIViewController {
    func showToast(message: String) {
        // Create banner container
        let banner = UIView()
        banner.backgroundColor = .systemBackground
        banner.layer.cornerRadius = 16
        banner.layer.shadowColor = UIColor.black.cgColor
        banner.layer.shadowOpacity = 0.15
        banner.layer.shadowOffset = CGSize(width: 0, height: 4)
        banner.layer.shadowRadius = 12
        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: 0, y: -100)
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        banner.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        // Message label
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        banner.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        // Add to window for top-level presentation (iOS 16+)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.addSubview(banner)
        
        banner.snp.makeConstraints { make in
            make.top.equalTo(window.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // Animate in
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            banner.alpha = 1
            banner.transform = .identity
        }
        
        // Animate out
        UIView.animate(withDuration: 0.3,
                       delay: 2.5,
                       options: [.curveEaseIn]) {
            banner.alpha = 0
            banner.transform = CGAffineTransform(translationX: 0, y: -100)
        } completion: { _ in
            banner.removeFromSuperview()
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
