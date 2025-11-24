//
//  PriceAlertCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.11.2025.
//

import UIKit
import SnapKit

final class PriceAlertCell: UITableViewCell {
    private let gameLabel = UILabel()
    private let priceLabel = UILabel()
    private let statusLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    var onToggle: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        // Toggle switch - önce ekle ki diğerleri buna referans verebilsin
        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        contentView.addSubview(toggleSwitch)
        toggleSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        // Game title
        gameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        gameLabel.numberOfLines = 2
        contentView.addSubview(gameLabel)
        gameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(toggleSwitch.snp.left).offset(-12)
        }
        
        // Price info
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .secondaryLabel
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(gameLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().inset(16)
            make.right.lessThanOrEqualTo(toggleSwitch.snp.left).offset(-12)
        }
        
        // Status
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textColor = .systemGreen
        contentView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    @objc private func switchToggled() {
        onToggle?()
    }
    
    func configure(with alert: PriceAlert) {
        gameLabel.text = alert.gameTitle
        
        if let current = alert.currentPrice {
            priceLabel.text = String(format: NSLocalizedString("priceAlerts.targetAndCurrent", comment: ""), alert.targetPrice, current)
        } else {
            priceLabel.text = String(format: NSLocalizedString("priceAlerts.targetPriceOnly", comment: ""), alert.targetPrice)
        }
        
        toggleSwitch.isOn = alert.isActive
        
        if alert.isActive {
            statusLabel.text = NSLocalizedString("priceAlerts.activeStatus", comment: "")
            statusLabel.textColor = .systemGreen
        } else {
            statusLabel.text = NSLocalizedString("priceAlerts.inactiveStatus", comment: "")
            statusLabel.textColor = .systemGray
        }
    }
}
