//
//  LiquidGlassCell.swift
//  Lissandr
//
//  Created by Umut Konmuş on 21.11.2025.
//

import UIKit
import SnapKit

final class LiquidGlassCell: UITableViewCell {
    
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBlur()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBlur()
    }
    
    private func setupBlur() {
        backgroundColor = .clear
        
        // Blur container with continuous corner curve (Apple's recommendation)
        blurView.layer.cornerRadius = 10
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        backgroundView = blurView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Position blur view
        blurView.frame = bounds.inset(by: UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        
        // Adjust content insets
        let inset: CGFloat = 16
        let detailWidth: CGFloat = 120 // Daha geniş alan
        
        textLabel?.frame = CGRect(
            x: blurView.frame.minX + inset,
            y: blurView.frame.minY,
            width: blurView.frame.width - inset * 2 - detailWidth - 8,
            height: blurView.frame.height
        )
        detailTextLabel?.frame = CGRect(
            x: blurView.frame.maxX - detailWidth - inset,
            y: blurView.frame.minY,
            width: detailWidth,
            height: blurView.frame.height
        )
        detailTextLabel?.textAlignment = .right
    }
}

final class LiquidGlassSwitchCell: UITableViewCell {
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let titleLabel = UILabel()
    private let toggleSwitch = UISwitch()
    
    var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Blur container with continuous corner curve (Apple's recommendation)
        blurView.layer.cornerRadius = 10
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        contentView.addSubview(blurView)
        blurView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16))
        }
        
        blurView.contentView.addSubview(titleLabel)
        titleLabel.font = .systemFont(ofSize: 17)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        blurView.contentView.addSubview(toggleSwitch)
        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        toggleSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func switchToggled() {
        onToggle?(toggleSwitch.isOn)
    }
    
    func configure(title: String, isOn: Bool) {
        titleLabel.text = title
        toggleSwitch.isOn = isOn
    }
}
