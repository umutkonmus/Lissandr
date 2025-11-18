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

        // 2) Watchlist
        let watchVC = WatchlistRouter.createModule()
        watchVC.title = "Takip Listem"
        let watchNav = UINavigationController(rootViewController: watchVC)
        watchNav.tabBarItem = UITabBarItem(title: "Takip",
                                           image: UIImage(systemName: "bookmark.fill"),
                                           selectedImage: UIImage(systemName: "bookmark.fill"))

        viewControllers = [dealsNav, watchNav]

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
