//
//  DealsListCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

final class DealsListCell: UITableViewCell {
    static let reuse = "DealsListCell"
    let cover = UIImageView()
    let titleLabel = UILabel()
    let storeLabel = UILabel()
    let priceLabel = UILabel()
    let oldPriceLabel = UILabel()
    let addButton = UIButton(type: .system)
    
    private var currentGameID: String?

    var onAddToWatchlist: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        selectionStyle = .none
        
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.layer.cornerRadius = 8
        contentView.addSubview(cover)
        cover.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.top.equalToSuperview().inset(12)
            make.width.height.equalTo(64)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(cover.snp.top)
            make.left.equalTo(cover.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().inset(12)
        }

        storeLabel.font = .preferredFont(forTextStyle: .subheadline)
        storeLabel.textColor = .secondaryLabel
        contentView.addSubview(storeLabel)
        storeLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        priceLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(storeLabel.snp.bottom).offset(6)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        oldPriceLabel.font = .preferredFont(forTextStyle: .subheadline)
        oldPriceLabel.textColor = .secondaryLabel
        contentView.addSubview(oldPriceLabel)
        oldPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(8)
            make.centerY.equalTo(priceLabel)
        }

        addButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        addButton.addAction(UIAction { [weak self] _ in 
            self?.handleBookmarkTap()
        }, for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }
    }
    
    private func handleBookmarkTap() {
        // gameID varsa ona göre, yoksa title'a göre kontrol et
        let watchlist = WatchlistStore.shared.load()
        
        if let gameID = currentGameID {
            // gameID ile kontrol
            if watchlist.contains(where: { $0.gameID == gameID }) {
                // Remove from watchlist
                WatchlistStore.shared.remove(gameID: gameID)
                addButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            } else {
                // Add to watchlist
                onAddToWatchlist?()
                addButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        } else if let title = titleLabel.text {
            // title ile kontrol (fallback for DealsList)
            if watchlist.contains(where: { $0.title == title }) {
                // Remove from watchlist by title
                if let item = watchlist.first(where: { $0.title == title }) {
                    WatchlistStore.shared.remove(gameID: item.gameID)
                    addButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
                }
            } else {
                // Add to watchlist
                onAddToWatchlist?()
                addButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            }
        } else {
            // Fallback: sadece ekle
            onAddToWatchlist?()
        }
    }

    func configure(title: String, store: String, price: String, oldPrice: String, thumbURL: String, gameID: String? = nil) {
        self.currentGameID = gameID
        
        titleLabel.text = title
        storeLabel.text = store
        priceLabel.text = "$\(price)"
        oldPriceLabel.attributedText = NSAttributedString(string: "₺\(oldPrice)", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        if let url = URL(string: thumbURL) {
            cover.kf.indicatorType = .activity
            cover.kf.setImage(with: url, options: [.transition(.fade(0.25)), .cacheOriginalImage])
        } else {
            cover.image = nil
        }
        
        // Update bookmark icon based on watchlist status
        let watchlist = WatchlistStore.shared.load()
        var isInWatchlist = false
        
        if let gameID = gameID {
            isInWatchlist = watchlist.contains(where: { $0.gameID == gameID })
        } else {
            // Fallback: title'a göre kontrol et
            isInWatchlist = watchlist.contains(where: { $0.title == title })
        }
        
        let iconName = isInWatchlist ? "bookmark.fill" : "bookmark"
        addButton.setImage(UIImage(systemName: iconName), for: .normal)
    }
}
