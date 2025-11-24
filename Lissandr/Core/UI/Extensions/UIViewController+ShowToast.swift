//
//  UIViewController+ShowToas.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.11.2025.
//

import UIKit
import SnapKit

extension UIViewController {
    func showToast(message: String) {
        // Create banner container
        let banner = UIView()
        banner.backgroundColor = .systemBackground
        banner.layer.cornerRadius = 16
        banner.layer.shadowColor = UIColor.black.cgColor
        banner.layer.shadowOpacity = 0.15
        banner.layer.shadowOffset = CGSize(width: 0, height: 4)
        banner.layer.shadowRadius = 12
        banner.alpha = 0
        banner.transform = CGAffineTransform(translationX: 0, y: -100)
        
        // Icon
        let iconView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        banner.addSubview(iconView)
        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        // Message label
        let label = UILabel()
        label.text = message
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 2
        banner.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(16)
        }
        
        // Add to window for top-level presentation (iOS 16+)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.addSubview(banner)
        
        banner.snp.makeConstraints { make in
            make.top.equalTo(window.safeAreaLayoutGuide).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }
        
        // Animate in
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [.curveEaseOut]) {
            banner.alpha = 1
            banner.transform = .identity
        }
        
        // Animate out
        UIView.animate(withDuration: 0.3,
                       delay: 2.5,
                       options: [.curveEaseIn]) {
            banner.alpha = 0
            banner.transform = CGAffineTransform(translationX: 0, y: -100)
        } completion: { _ in
            banner.removeFromSuperview()
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
