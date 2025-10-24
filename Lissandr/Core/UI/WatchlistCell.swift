//
//  WatchlistCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit
import SnapKit
import Kingfisher

final class WatchlistCell: UITableViewCell {
    static let reuse = "WatchlistCell"
    private let thumbImageView = UIImageView()
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
        
        thumbImageView.layer.cornerRadius = 8
        thumbImageView.clipsToBounds = true
        thumbImageView.backgroundColor = UIColor.systemGray4
        contentView.addSubview(thumbImageView)
        thumbImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(64)
            make.top.greaterThanOrEqualToSuperview().inset(12)
            make.bottom.lessThanOrEqualToSuperview().inset(12)
        }
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.left.equalTo(thumbImageView.snp.right).offset(12)
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
    
    func configure(title: String, lastKnown: Double?, current: Double?, thumbURL: String?) {
        titleLabel.text = title
        
        if let c = current {
            priceLabel.text = String(format: "$%.2f", c)
        } else if let o = lastKnown {
            priceLabel.text = String(format: "Son fiyat: $%.2f", o)
        } else {
            priceLabel.text = "—"
        }
        
        if let o = lastKnown, let c = current, o > c {
            oldPriceLabel.attributedText = NSAttributedString(
                string: String(format: "$%.2f", o),
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        } else if let _ = lastKnown, current == nil {
            oldPriceLabel.text = ""
        } else {
            oldPriceLabel.text = ""
        }
        
        if let urlString = thumbURL, let url = URL(string: urlString) {
            thumbImageView.kf.setImage(with: url, placeholder: nil, options: nil, completionHandler: nil)
            thumbImageView.backgroundColor = .clear
        } else {
            thumbImageView.image = nil
            thumbImageView.backgroundColor = UIColor.systemGray4
        }
    }
}
