//
//  WatchlistViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit
import SnapKit


final class WatchlistViewController: UIViewController, WatchlistViewProtocol, UITableViewDataSource, UITableViewDelegate {
    var presenter: WatchlistPresenterProtocol!

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activity = UIActivityIndicatorView(style: .large)
    private var refresher = UIRefreshControl()

    private var rows: [WatchRow] = [] // derived model for UI

    struct WatchRow { let gameID: String; let title: String; var lastKnown: Double?; var current: Double?; var thumb: String? }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Extended layout
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // Large title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        title = "Takip Listem"

        // Table
        view.addSubview(tableView)
        tableView.dataSource = self; tableView.delegate = self
        tableView.register(WatchlistCell.self, forCellReuseIdentifier: WatchlistCell.reuse)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.refreshControl = refresher
        refresher.addTarget(self, action: #selector(onPull), for: .valueChanged)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }

        // Activity
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }

        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.refresh()
    }

    @objc private func onPull() { presenter.refresh() }

    // MARK: View Protocol
    func show(items: [WatchItem]) {
        rows = items.map { .init(gameID: $0.gameID, title: $0.title, lastKnown: $0.lastKnownPrice, current: nil, thumb: nil) }
        tableView.reloadData()
    }

    func updatePrice(for gameID: String, price: Double?) {
        if let idx = rows.firstIndex(where: { $0.gameID == gameID }) {
            rows[idx].current = price
            if let visible = tableView.indexPathsForVisibleRows, visible.contains(IndexPath(row: idx, section: 0)) {
                tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .fade)
            }
        }
    }

    func updateThumb(for gameID: String, url: String?) {
        if let idx = rows.firstIndex(where: { $0.gameID == gameID }) {
            rows[idx].thumb = url
            if let visible = tableView.indexPathsForVisibleRows, visible.contains(IndexPath(row: idx, section: 0)) {
                tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .none)
            }
        }
    }

    func showLoading(_ loading: Bool) {
        DispatchQueue.main.async {
            loading ? self.activity.startAnimating() : self.activity.stopAnimating()
            if !loading {
                self.refresher.endRefreshing()
            }
        }
    }

    func showError(_ message: String) {
        let ac = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(ac, animated: true)
    }

    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistCell.reuse, for: indexPath) as! WatchlistCell
        let r = rows[indexPath.row]
        cell.configure(title: r.title, lastKnown: r.lastKnown, current: r.current, thumbURL: r.thumb)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didTapGame(at: indexPath.row)
    }
    
    // Swipe to delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil") { [weak self] _, _, done in
            self?.presenter.delete(at: indexPath.row)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
