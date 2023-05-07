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
        
        let navHomeController = UINavigationController(rootViewController: HomeController)
        let navScannerViewController = UINavigationController(rootViewController: ScannerViewController)
        
        navHomeController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "books.vertical.fill"), tag: 0)
        navScannerViewController.tabBarItem = UITabBarItem(title: "Scanner", image: UIImage(systemName: "barcode.viewfinder"), tag: 1)
        
        navHomeController.tabBarItem.badgeColor = .label
        navScannerViewController.tabBarItem.badgeColor = .label
        
        tabBar.tintColor = .label
        tabBar.backgroundColor = .secondarySystemBackground
        
        setViewControllers([navHomeController, navScannerViewController], animated: false)
    }
}
