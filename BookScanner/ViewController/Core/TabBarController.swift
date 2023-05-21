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
            try await reloadViewController()
            signInStatusListener()
        }
    }
    
    func reloadViewController() async throws {
        guard let currentUser = try await validateSignInStatus() else {
            removeAllViewControllersAndShowSignIn()
            
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
    
    func signInStatusListener() {
        Auth.auth().addStateDidChangeListener { auth, user in
            Task {
                guard try await self.validateSignInStatus() != nil else {
                    self.removeAllViewControllersAndShowSignIn()
                    return
                }
            }
        }
    }
    
    func validateSignInStatus() async throws -> User? {
        guard let authCurrentUser = Auth.auth().currentUser else { return nil }
        guard let currentUser = try await DatabaseHandler.shared.getUserByUserID(authCurrentUser.uid) else {
            _ = try? Auth.auth().signOut()
            
            return nil
        }
        
        return currentUser
    }
    
    func removeAllViewControllersAndShowSignIn() {
        DispatchQueue.main.async {
            let signInController = SignInController()
            signInController.hidesBottomBarWhenPushed = true
            signInController.navigationItem.hidesBackButton = true
            self.navigationController?.pushViewController(signInController, animated: false)
        }
        
        setViewControllers(nil, animated: false)
    }
}
