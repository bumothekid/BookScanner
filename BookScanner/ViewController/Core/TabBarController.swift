//
//  TabBarController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        guard Auth.auth().currentUser != nil else {
            let signUpController = UIViewController
            navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
            return
        }
        
        super.viewDidLoad()

        let HomeController = SecHomeController()
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
