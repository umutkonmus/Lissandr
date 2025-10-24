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
            make.size.equalTo(CGSize(width: 64, height: 64))
            make.left.top.equalToSuperview().inset(12)
        }

        titleLabel.font = .preferredFont(forTextStyle: .headline)
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
        }

        oldPriceLabel.font = .preferredFont(forTextStyle: .subheadline)
        oldPriceLabel.textColor = .secondaryLabel
        contentView.addSubview(oldPriceLabel)
        oldPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(8)
            make.centerY.equalTo(priceLabel)
        }

        addButton.setTitle("Takip Et", for: .normal)
        addButton.addAction(UIAction { [weak self] _ in self?.onAddToWatchlist?() }, for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
        }
    }

    func configure(title: String, store: String, price: String, oldPrice: String, thumbURL: String) {
        titleLabel.text = title
        storeLabel.text = store
        priceLabel.text = "₺\(price)"
        oldPriceLabel.attributedText = NSAttributedString(string: "₺\(oldPrice)", attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
        if let url = URL(string: thumbURL) {
            cover.kf.indicatorType = .activity
            cover.kf.setImage(with: url, options: [.transition(.fade(0.25)), .cacheOriginalImage])
        } else {
            cover.image = nil
        }
    }
}
