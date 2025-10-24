//
//  WatchlistCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit
import SnapKit

final class WatchlistCell: UITableViewCell {
    static let reuse = "WatchlistCell"
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let oldPriceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        selectionStyle = .none

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.left.equalToSuperview().inset(16)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }

        priceLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(12)
        }

        oldPriceLabel.font = .preferredFont(forTextStyle: .subheadline)
        oldPriceLabel.textColor = .secondaryLabel
        contentView.addSubview(oldPriceLabel)
        oldPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceLabel.snp.right).offset(8)
            make.centerY.equalTo(priceLabel)
            make.right.lessThanOrEqualToSuperview().inset(16)
        }
    }

    func configure(title: String, lastKnown: Double?, current: Double?) {
        titleLabel.text = title
        if let c = current {
            priceLabel.text = String(format: "$%.2f", c)
        } else {
            priceLabel.text = "Güncelleniyor…"
        }
        if let o = lastKnown {
            oldPriceLabel.attributedText = NSAttributedString(
                string: String(format: "$%.2f", o),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else {
            oldPriceLabel.text = ""
        }
    }
}

