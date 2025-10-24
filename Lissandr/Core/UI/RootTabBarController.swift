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

        // 1) Deals
        let dealsVC = DealsListRouter.createModule()  
        dealsVC.title = "Fırsatlar"
        let dealsNav = UINavigationController(rootViewController: dealsVC)
        dealsNav.tabBarItem = UITabBarItem(title: "Fırsatlar",
                                           image: UIImage(systemName: "tag.fill"),
                                           selectedImage: UIImage(systemName: "tag.fill"))

        // 2) Search
        let searchVC = SearchRouter.createModule()
        searchVC.title = "Ara"
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "Ara",
                                            image: UIImage(systemName: "magnifyingglass"),
                                            selectedImage: UIImage(systemName: "magnifyingglass"))

        // 3) Watchlist
        let watchVC = WatchlistRouter.createModule()
        watchVC.title = "Takip"
        let watchNav = UINavigationController(rootViewController: watchVC)
        watchNav.tabBarItem = UITabBarItem(title: "Takip",
                                           image: UIImage(systemName: "bookmark.fill"),
                                           selectedImage: UIImage(systemName: "bookmark.fill"))

        viewControllers = [dealsNav, searchNav, watchNav]

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithDefaultBackground()
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
