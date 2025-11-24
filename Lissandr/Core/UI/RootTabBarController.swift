//
//  RootTabBarController.swift
//  Lissandr
//
//  Created by Umut Konmuş on 24.10.2025.
//

import UIKit

final class RootTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tabBar.tintColor = .systemPink

        // 1) Deals (Ana Ekran)
        let dealsVC = DealsListRouter.createModule()  
        dealsVC.title = String(localized: "deals.title", comment: "Deals screen title")
        let dealsNav = UINavigationController(rootViewController: dealsVC)
        dealsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.home", comment: "Home tab title"),
            image: UIImage(systemName: "house.fill"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        // 2) Watchlist
        let watchVC = WatchlistRouter.createModule()
        watchVC.title = String(localized: "watchlist.title", comment: "Watchlist screen title")
        let watchNav = UINavigationController(rootViewController: watchVC)
        watchNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.watchlist", comment: "Watchlist tab title"),
            image: UIImage(systemName: "bookmark.fill"),
            selectedImage: UIImage(systemName: "bookmark.fill")
        )

        // 3) Settings (Ayarlar)
        let settingsVC = AppSettingsRouter.createModule()
        settingsVC.title = String(localized: "settings.title", comment: "Settings screen title")
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: String(localized: "tab.settings", comment: "Settings tab title"),
            image: UIImage(systemName: "gearshape.fill"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        // 4) Search (Arama) - Sağda ayrı
        let searchVC = SearchRouter.createModule()
        searchVC.title = String(localized: "search.title", comment: "Search screen title")
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)

        viewControllers = [dealsNav, watchNav, settingsNav, searchNav]

    }
}
