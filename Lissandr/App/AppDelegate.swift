//
//  AppDelegate.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let priceDropTaskId = "com.uk.Lissandr.pricedrop.refresh"

    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: priceDropTaskId, using: nil) { task in
            self.handlePriceDropTask(task: task as! BGAppRefreshTask)
        }
    }

    func schedulePriceDropTask() {
        let req = BGAppRefreshTaskRequest(identifier: priceDropTaskId)
        req.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60)
        do { try BGTaskScheduler.shared.submit(req) }
        catch { print("BG submit error: \(error)") }
    }

    func handlePriceDropTask(task: BGAppRefreshTask) {
        schedulePriceDropTask()

        task.expirationHandler = {
            // IF NEED
        }

        Task {
            await PriceDropService.shared.checkWatchlistForDrops()
            task.setTaskCompleted(success: true)
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        schedulePriceDropTask()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // İlk açılışta bildirimleri varsayılan olarak aç
        if !UserDefaults.standard.bool(forKey: "has_launched_before") {
            UserDefaults.standard.set(true, forKey: "has_launched_before")
            UserDefaults.standard.set(true, forKey: "notifications_enabled")
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error { print("Notification auth error: \(error)") }
            if !granted {
                // Kullanıcı izin vermediyse ayarı kapat
                UserDefaults.standard.set(false, forKey: "notifications_enabled")
            }
        }
        registerBackgroundTasks()
        schedulePriceDropTask()
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

