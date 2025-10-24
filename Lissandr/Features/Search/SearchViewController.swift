//
//  SearchViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit

final class SearchViewController: UIViewController, SearchViewProtocol, UITableViewDataSource, UITableViewDelegate {
    var presenter: SearchPresenterProtocol!
    private var results: [GameSearchItem] = []
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchBar = LiquidSearchBar()
    private let activity = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(tableView)
        tableView.dataSource = self; tableView.delegate = self
        tableView.register(ResultCell.self, forCellReuseIdentifier: ResultCell.reuse)
        tableView.keyboardDismissMode = .onDrag
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        view.addSubview(searchBar)
        searchBar.onSubmit = { [weak self] q in self?.presenter.submit(query: q) }
        searchBar.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12) // bottom-floating
            make.height.equalTo(44)
        }
        
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    func showResults(_ items: [GameSearchItem]) { results = items; DispatchQueue.main.async { self.tableView.reloadData() } }
    func showLoading(_ loading: Bool) { DispatchQueue.main.async { loading ? self.activity.startAnimating() : self.activity.stopAnimating() } }
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Tamam", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    // MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { results.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ResultCell.reuse, for: indexPath) as! ResultCell
        let r = results[indexPath.row]
        cell.configure(title: r.external, price: r.cheapest, thumb: r.thumb)
        cell.onAdd = { [weak self] in self?.presenter.addToWatchlist(index: indexPath.row) }
        return cell
    }
}
