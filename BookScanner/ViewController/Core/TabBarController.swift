//
//  TabBarController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import FirebaseAuth

class TabBarController: UITabBarController {
    
    var userProfile: User! {
        didSet {
            for navController in viewControllers ?? [UIViewController]() {
                guard let vc = (navController as? UINavigationController)?.viewControllers.first else { return }
                if let homeVC = vc as? HomeController {
                    homeVC.userProfile = userProfile
                }
                
                if let scanVC = vc as? ScannerViewController {
                    scanVC.userProfile = userProfile
                }
                
                if let searchVC = vc as? SearchViewController {
                    searchVC.userProfile = userProfile
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            try await reloadViewController()
            signInStatusListener()
            userProfileValueListener()
        }
    }
    
    func reloadViewController() async throws {
        guard let currentUser = try await validateSignInStatus() else {
            removeAllViewControllersAndShowSignIn()
            
            return
        }
        
        userProfile = currentUser
        
        try await BookHandler().refreshUserDefaults(userProfile)
        
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
                guard let currentUser = try await self.validateSignInStatus() else {
                    self.removeAllViewControllersAndShowSignIn()
                    return
                }
                
                self.userProfile = currentUser
            }
        }
    }
    
    func userProfileValueListener() {
        guard userProfile != nil else { return }
        
        DatabaseHandler.shared.addSnapshotListenerForUID(userProfile.uid) { user in
            guard let user = user else { return }
            
            self.userProfile = user
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
