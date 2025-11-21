//
//  GameDetailViewController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 18.11.2025.
//

import UIKit
import SnapKit
import Kingfisher

final class GameDetailViewController: UIViewController, GameDetailViewProtocol {
    var presenter: GameDetailPresenterProtocol!
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let activity = UIActivityIndicatorView(style: .large)
    
    private var gameData: GameDetailData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Oyun Detayı"
        
        // Navigation bar buttons
        let bookmarkButton = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(addToWatchlistTapped)
        )
        
        let alertButton = UIBarButtonItem(
            image: UIImage(systemName: "bell.badge"),
            style: .plain,
            target: self,
            action: #selector(setPriceAlertTapped)
        )
        
        navigationItem.rightBarButtonItems = [bookmarkButton, alertButton]
        
        // ScrollView
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        
        // Content Stack
        scrollView.addSubview(contentStack)
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalTo(scrollView.snp.width).offset(-32)
        }
        
        // Activity
        view.addSubview(activity)
        activity.hidesWhenStopped = true
        activity.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    @objc private func addToWatchlistTapped() {
        guard let gameData = gameData else { return }
        
        // Check if already in watchlist
        let watchlist = WatchlistStore.shared.load()
        if watchlist.contains(where: { $0.gameID == gameData.gameID }) {
            // Remove from watchlist
            WatchlistStore.shared.remove(gameID: gameData.gameID)
            updateBookmarkIcon()
            showToast(message: "\(gameData.title) takip listesinden çıkarıldı")
        } else {
            // Add to watchlist
            presenter.didTapAddToWatchlist()
            updateBookmarkIcon()
        }
    }
    
    private func updateBookmarkIcon() {
        guard let gameData = gameData else { return }
        
        let watchlist = WatchlistStore.shared.load()
        let isInWatchlist = watchlist.contains(where: { $0.gameID == gameData.gameID })
        
        let iconName = isInWatchlist ? "bookmark.fill" : "bookmark"
        navigationItem.rightBarButtonItems?.first?.image = UIImage(systemName: iconName)
    }
    
    @objc private func setPriceAlertTapped() {
        presenter.didTapSetPriceAlert()
    }
    
    func showPriceAlertDialog(currentPrice: Double, gameTitle: String) {
        guard let gameData = gameData else { return }
        
        // Mevcut alarm var mı kontrol et
        if let existingAlert = PriceAlertStore.shared.hasActiveAlert(for: gameData.gameID) {
            showUpdateAlertDialog(existingAlert: existingAlert, currentPrice: currentPrice)
            return
        }
        
        // Yeni alarm kur
        let alert = UIAlertController(
            title: "Fiyat Alarmı Kur",
            message: "Güncel fiyat: $\(String(format: "%.2f", currentPrice))\n\nHedef fiyatınızı girin:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Örn: \(String(format: "%.2f", currentPrice * 0.8))"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.2f", currentPrice * 0.8)
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Alarm Kur", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let targetPrice = Double(text),
                  let gameData = self.gameData else { return }
            
            if targetPrice >= currentPrice {
                self.showToast(message: "Hedef fiyat güncel fiyattan düşük olmalı")
                return
            }
            
            let priceAlert = PriceAlert(
                gameID: gameData.gameID,
                gameTitle: gameData.title,
                targetPrice: targetPrice,
                currentPrice: currentPrice
            )
            
            PriceAlertStore.shared.add(priceAlert)
            self.showToast(message: "Fiyat alarmı kuruldu! $\(String(format: "%.2f", targetPrice))")
        })
        
        present(alert, animated: true)
    }
    
    private func showUpdateAlertDialog(existingAlert: PriceAlert, currentPrice: Double) {
        let alert = UIAlertController(
            title: "Mevcut Alarm",
            message: "Bu oyun için zaten bir alarm var:\nHedef: $\(String(format: "%.2f", existingAlert.targetPrice))\n\nNe yapmak istersiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Fiyatı Güncelle", style: .default) { [weak self] _ in
            self?.showUpdatePriceDialog(existingAlert: existingAlert, currentPrice: currentPrice)
        })
        
        alert.addAction(UIAlertAction(title: "Alarmı Sil", style: .destructive) { [weak self] _ in
            PriceAlertStore.shared.remove(id: existingAlert.id)
            self?.showToast(message: "Alarm silindi")
        })
        
        present(alert, animated: true)
    }
    
    private func showUpdatePriceDialog(existingAlert: PriceAlert, currentPrice: Double) {
        let alert = UIAlertController(
            title: "Hedef Fiyatı Güncelle",
            message: "Güncel fiyat: $\(String(format: "%.2f", currentPrice))\n\nYeni hedef fiyatı girin:",
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.placeholder = "Örn: \(String(format: "%.2f", currentPrice * 0.8))"
            textField.keyboardType = .decimalPad
            textField.text = String(format: "%.2f", existingAlert.targetPrice)
        }
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Güncelle", style: .default) { [weak self] _ in
            guard let self = self,
                  let text = alert.textFields?.first?.text,
                  let targetPrice = Double(text),
                  let gameData = self.gameData else { return }
            
            if targetPrice >= currentPrice {
                self.showToast(message: "Hedef fiyat güncel fiyattan düşük olmalı")
                return
            }
            
            let updatedAlert = PriceAlert(
                gameID: gameData.gameID,
                gameTitle: gameData.title,
                targetPrice: targetPrice,
                currentPrice: currentPrice
            )
            
            PriceAlertStore.shared.updateOrAdd(updatedAlert)
            self.showToast(message: "Alarm güncellendi! $\(String(format: "%.2f", targetPrice))")
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - View Protocol
    
    func displayGame(_ game: GameDetailData) {
        self.gameData = game
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            // Update bookmark icon
            self.updateBookmarkIcon()
            
            // Clear existing views
            self.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            
            // Header (Image + Title)
            let header = self.createHeader(game: game)
            self.contentStack.addArrangedSubview(header)
            
            // Price info
            let priceInfo = self.createPriceInfo(game: game)
            self.contentStack.addArrangedSubview(priceInfo)
            
            // Deals table
            if !game.deals.isEmpty {
                let dealsView = self.createDealsTable(deals: game.deals)
                self.contentStack.addArrangedSubview(dealsView)
            }
        }
    }
    
    func showLoading(_ loading: Bool) {
        DispatchQueue.main.async { [weak self] in
            loading ? self?.activity.startAnimating() : self?.activity.stopAnimating()
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    // MARK: - UI Creation
    
    private func createHeader(game: GameDetailData) -> UIView {
        let container = UIView()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        if let url = URL(string: game.thumb) {
            imageView.kf.setImage(with: url)
        }
        container.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = game.title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        return container
    }
    
    private func createPriceInfo(game: GameDetailData) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 12
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 1
        container.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(16) }
        
        // Current Price
        let currentStack = createPriceColumn(
            title: "Güncel Fiyat",
            price: game.currentPrice
        )
        stack.addArrangedSubview(currentStack)
        
        // Historical Low
        let lowStack = createPriceColumn(
            title: "En Düşük Fiyat",
            price: game.historicalLow
        )
        stack.addArrangedSubview(lowStack)
        
        return container
    }
    
    private func createPriceColumn(title: String, price: Double?) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        stack.addArrangedSubview(titleLabel)
        
        let priceLabel = UILabel()
        if let price = price {
            priceLabel.text = String(format: "$%.2f", price)
            priceLabel.font = .systemFont(ofSize: 28, weight: .bold)
            priceLabel.textColor = .systemGreen
        } else {
            priceLabel.text = "-"
            priceLabel.font = .systemFont(ofSize: 28, weight: .bold)
            priceLabel.textColor = .secondaryLabel
        }
        stack.addArrangedSubview(priceLabel)
        
        return stack
    }
    
    private func createDealsTable(deals: [(String, Double, Double)]) -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "Mağaza Fiyatları"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        container.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        container.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        
        for deal in deals {
            let row = createDealRow(storeName: deal.0, price: deal.1, retailPrice: deal.2)
            stack.addArrangedSubview(row)
        }
        
        return container
    }
    
    private func createDealRow(storeName: String, price: Double, retailPrice: Double) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 8
        
        let storeLabel = UILabel()
        storeLabel.text = storeName
        storeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        container.addSubview(storeLabel)
        storeLabel.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(12)
            make.right.lessThanOrEqualToSuperview().inset(120)
        }
        
        let priceLabel = UILabel()
        priceLabel.text = String(format: "$%.2f", price)
        priceLabel.font = .systemFont(ofSize: 18, weight: .bold)
        priceLabel.textColor = .systemGreen
        container.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }
        
        if retailPrice > price {
            let oldPriceLabel = UILabel()
            oldPriceLabel.attributedText = NSAttributedString(
                string: String(format: "$%.2f", retailPrice),
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.secondaryLabel
                ]
            )
            oldPriceLabel.font = .systemFont(ofSize: 14)
            container.addSubview(oldPriceLabel)
            oldPriceLabel.snp.makeConstraints { make in
                make.right.equalTo(priceLabel.snp.left).offset(-8)
                make.centerY.equalToSuperview()
            }
        }
        
        return container
    }
}
