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
    
    func notifyPriceDrop(title: String, oldPrice: Double?, newPrice: Double) {
        let content = UNMutableNotificationContent()
        content.title = "İndirim! \(title)"
        if let old = oldPrice {
            content.body = String(format: "$%.2f → $%.2f", old, newPrice)
        } else {
            content.body = String(format: "Yeni fiyat: $%.2f", newPrice)
        }
        content.sound = .default
        // Deep link
        content.userInfo = ["route": "watchlist"]  // basit bir işaret
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }
}
