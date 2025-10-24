//
//  ResultCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

final class ResultCell: UITableViewCell {
    static let reuse = "ResultCell"
    let cover = UIImageView(); let titleLabel = UILabel(); let priceLabel = UILabel(); let addButton = UIButton(type: .system)
    var onAdd: (() -> Void)?
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { super.init(style: style, reuseIdentifier: reuseIdentifier); setup() }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }
    private func setup() {
        selectionStyle = .none
        cover.layer.cornerRadius = 8; cover.clipsToBounds = true; cover.contentMode = .scaleAspectFill
        contentView.addSubview(cover)
        cover.snp.makeConstraints { make in make.left.top.bottom.equalToSuperview().inset(12); make.width.equalTo(56) }
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in make.left.equalTo(cover.snp.right).offset(10); make.top.equalTo(cover) }
        priceLabel.font = .preferredFont(forTextStyle: .subheadline); priceLabel.textColor = .secondaryLabel
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in make.left.equalTo(titleLabel); make.top.equalTo(titleLabel.snp.bottom).offset(6) }
        addButton.setTitle("Takip Et", for: .normal)
        addButton.addAction(UIAction { [weak self] _ in self?.onAdd?() }, for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in make.centerY.equalToSuperview(); make.right.equalToSuperview().inset(12) }
    }
    func configure(title: String, price: String, thumb: String) {
        titleLabel.text = title
        priceLabel.text = "En ucuz: ₺\(price)"
        if let url = URL(string: thumb) {
            cover.kf.indicatorType = .activity
            cover.kf.setImage(with: url, options: [.transition(.fade(0.25)), .cacheOriginalImage])
        } else {
            cover.image = nil
        }
    }
}
