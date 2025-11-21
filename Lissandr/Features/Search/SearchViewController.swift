//
//  SearchViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit

final class SearchViewController: UIViewController, SearchViewProtocol, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var presenter: SearchPresenterProtocol!
    private var results: [GameSearchItem] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)
    private let activity = UIActivityIndicatorView(style: .large)
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Extended layout
        edgesForExtendedLayout = [.top, .bottom]
        extendedLayoutIncludesOpaqueBars = true
        
        // Search Controller setup (Apple Music style)
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Oyun ara..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        // TableView
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DealsListCell.self, forCellReuseIdentifier: DealsListCell.reuse)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        // Empty state
        emptyLabel.text = "Oyun aramak için yukarıdaki arama çubuğunu kullanın"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .preferredFont(forTextStyle: .body)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload to update bookmark icons
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Auto-focus search bar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        searchBar.resignFirstResponder()
        presenter.submit(query: query)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Optional: implement live search
        if searchText.isEmpty {
            results = []
            tableView.reloadData()
            emptyLabel.isHidden = false
        }
    }

    // MARK: View Protocol
    func showResults(_ items: [GameSearchItem]) { 
        results = items
        DispatchQueue.main.async { 
            self.emptyLabel.isHidden = !items.isEmpty
            self.tableView.reloadData() 
        }
    }
    
    func showLoading(_ loading: Bool) { 
        DispatchQueue.main.async { 
            loading ? self.activity.startAnimating() : self.activity.stopAnimating()
            self.emptyLabel.isHidden = loading || !self.results.isEmpty
        }
    }
    
    func showError(_ message: String) { 
        DispatchQueue.main.async { 
            let ac = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    func updateRow(at index: Int, storeName: String?, oldPrice: String?) {
        guard index < results.count else { return }
        if let visible = tableView.indexPathsForVisibleRows, visible.contains(IndexPath(row: index, section: 0)) {
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }

    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { results.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DealsListCell.reuse, for: indexPath) as! DealsListCell
        let r = results[indexPath.row]
        let info = presenter.displayInfo(for: indexPath.row)
        let storeText = info.storeName ?? "Mağaza bekleniyor…"
        let oldPriceText = info.oldPrice ?? "-"
        let gameID = presenter.getGameID(at: indexPath.row)
        cell.configure(title: r.external, store: storeText, price: r.cheapest, oldPrice: oldPriceText, thumbURL: r.thumb, gameID: gameID)
        cell.onAddToWatchlist = { [weak self] in 
            self?.presenter.addToWatchlist(index: indexPath.row)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.requestDetail(for: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter.didTapGame(index: indexPath.row)
    }
}


