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
    private var searchBarBottomConstraint: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // TableView
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DealsListCell.self, forCellReuseIdentifier: DealsListCell.reuse)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }

        // Search bar
        view.addSubview(searchBar)
        searchBar.onSubmit = { [weak self] q in self?.presenter.submit(query: q) }
        searchBar.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            self.searchBarBottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).inset(12).constraint
            make.height.equalTo(44)
        }

        // Activity
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    // MARK: Keyboard
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func handleKeyboard(notification: Notification) {
        guard let info = notification.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curveRaw = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt,
              let endFrame = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let endInView = view.convert(endFrame, from: nil)
        let overlap = max(0, view.bounds.maxY - endInView.origin.y)
        let extra = max(0, overlap - view.safeAreaInsets.bottom)
        searchBarBottomConstraint?.update(inset: 12 + extra)
        var inset = tableView.contentInset
        inset.bottom = extra + 60
        tableView.contentInset = inset
        tableView.verticalScrollIndicatorInsets.bottom = inset.bottom
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curveRaw << 16), animations: { self.view.layoutIfNeeded() }, completion: nil)
    }

    // MARK: View Protocol
    func showResults(_ items: [GameSearchItem]) { results = items; DispatchQueue.main.async { self.tableView.reloadData() } }
    func showLoading(_ loading: Bool) { DispatchQueue.main.async { loading ? self.activity.startAnimating() : self.activity.stopAnimating() } }
    func showError(_ message: String) { DispatchQueue.main.async { let ac = UIAlertController(title: "Hata", message: message, preferredStyle: .alert); ac.addAction(UIAlertAction(title: "Tamam", style: .default)); self.present(ac, animated: true) } }
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
        cell.configure(title: r.external, store: storeText, price: r.cheapest, oldPrice: oldPriceText, thumbURL: r.thumb)
        cell.onAddToWatchlist = { [weak self] in self?.presenter.addToWatchlist(index: indexPath.row) }
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


