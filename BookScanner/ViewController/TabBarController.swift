//
//  TabBarController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let HomeController = HomeController()
        let ScannerViewController = ScannerViewController()
        let ProfileController = ProfileController()
        
        let navHomeController = UINavigationController(rootViewController: HomeController)
        let navScannerViewController = UINavigationController(rootViewController: ScannerViewController)
        let navProfileController = UINavigationController(rootViewController: ProfileController)
        
        navHomeController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "books.vertical.fill"), tag: 0)
        navScannerViewController.tabBarItem = UITabBarItem(title: "Scanner", image: UIImage(systemName: "barcode.viewfinder"), tag: 1)
        navProfileController.tabBarItem = UITabBarItem(title: "David", image: UIImage(systemName: "person"), tag: 2)
        
        navHomeController.tabBarItem.badgeColor = .label
        navScannerViewController.tabBarItem.badgeColor = .label
        navProfileController.tabBarItem.badgeColor = .label
        
        tabBar.tintColor = .label
        tabBar.backgroundColor = .secondarySystemBackground
        
        setViewControllers([navHomeController, navScannerViewController, navProfileController], animated: false)
    }
}
