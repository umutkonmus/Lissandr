//
//  NotificationManager.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager(); private init() {}
    
    private func areNotificationsEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
    
    func notifyPriceDrop(title: String, oldPrice: Double?, newPrice: Double) {
        guard areNotificationsEnabled() else {
            print("Bildirimler kapalı - fiyat düşüşü bildirimi gönderilmedi")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "İndirim! \(title)"
        if let old = oldPrice {
            content.body = String(format: "$%.2f → $%.2f", old, newPrice)
        } else {
            content.body = String(format: "Yeni fiyat: $%.2f", newPrice)
        }
        content.sound = .default
        content.userInfo = ["route": "watchlist"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
    
    func notifyPriceAlert(title: String, targetPrice: Double, currentPrice: Double) {
        guard areNotificationsEnabled() else {
            print("Bildirimler kapalı - fiyat alarmı bildirimi gönderilmedi")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "🎯 Fiyat Alarmı!"
        content.body = String(format: "%@ hedef fiyatınıza ulaştı!\nHedef: $%.2f → Güncel: $%.2f", title, targetPrice, currentPrice)
        content.sound = .defaultCritical
        content.userInfo = ["route": "watchlist"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}
