//
//  TabBarController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            guard Auth.auth().currentUser != nil, let currentUser = try await DatabaseHandler.shared.getUserByUserID(Auth.auth().currentUser!.uid) else {
                if Auth.auth().currentUser != nil {
                    do {
                        try Auth.auth().signOut()
                    }
                    catch {
                        
                    }
                }
                
                DispatchQueue.main.async {
                    let signInController = SignInController()
                    signInController.hidesBottomBarWhenPushed = true
                    signInController.navigationItem.hidesBackButton = true
                    self.navigationController?.pushViewController(signInController, animated: false)
                }
                
                return
            }
            
            try await BookHandler().refreshUserDefaults(currentUser)
            
            let HomeController = HomeController(profile: currentUser)
            let ScannerViewController = ScannerViewController(profile: currentUser)
            let SearchController = SearchViewController(profile: currentUser)
            
            let navHomeController = UINavigationController(rootViewController: HomeController)
            let navScannerViewController = UINavigationController(rootViewController: ScannerViewController)
            let navSearchController = UINavigationController(rootViewController: SearchController)
            
            navHomeController.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "books.vertical.fill"), tag: 0)
            navScannerViewController.tabBarItem = UITabBarItem(title: "Scanner", image: UIImage(systemName: "barcode.viewfinder"), tag: 1)
            navSearchController.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 2)
            
            navHomeController.tabBarItem.badgeColor = .label
            navScannerViewController.tabBarItem.badgeColor = .label
            navSearchController.tabBarItem.badgeColor = .label
            
            tabBar.tintColor = .label
            tabBar.backgroundColor = .secondarySystemBackground
            
            setViewControllers([navHomeController, navScannerViewController, navSearchController], animated: false)
        }
    }
}
