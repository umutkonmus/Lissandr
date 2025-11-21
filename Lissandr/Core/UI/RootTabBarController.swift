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
        tabBar.isTranslucent = false

        // 1) Deals (Ana Ekran)
        let dealsVC = DealsListRouter.createModule()  
        dealsVC.title = "Fırsatlar"
        let dealsNav = UINavigationController(rootViewController: dealsVC)
        dealsNav.tabBarItem = UITabBarItem(title: "Ana Sayfa",
                                           image: UIImage(systemName: "house.fill"),
                                           selectedImage: UIImage(systemName: "house.fill"))

        // 2) Search (Arama)
        let searchVC = SearchRouter.createModule()
        searchVC.title = "Ara"
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Ara",
                                            image: UIImage(systemName: "magnifyingglass"),
                                            selectedImage: UIImage(systemName: "magnifyingglass"))

        // 3) Watchlist
        let watchVC = WatchlistRouter.createModule()
        watchVC.title = "Takip Listem"
        let watchNav = UINavigationController(rootViewController: watchVC)
        watchNav.tabBarItem = UITabBarItem(title: "Takip",
                                           image: UIImage(systemName: "bookmark.fill"),
                                           selectedImage: UIImage(systemName: "bookmark.fill"))

        // 4) Settings (Ayarlar)
        let settingsVC = AppSettingsRouter.createModule()
        settingsVC.title = "Ayarlar"
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Ayarlar",
                                              image: UIImage(systemName: "gearshape.fill"),
                                              selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [dealsNav, searchNav, watchNav, settingsNav]

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
