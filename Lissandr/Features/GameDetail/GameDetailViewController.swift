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
        
        // Add to Watchlist button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(addToWatchlistTapped)
        )
        
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
        presenter.didTapAddToWatchlist()
    }
    
    // MARK: - View Protocol
    
    func displayGame(_ game: GameDetailData) {
        self.gameData = game
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
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
