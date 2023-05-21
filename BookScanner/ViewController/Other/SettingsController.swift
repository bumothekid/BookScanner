//
//  SettingsController.swift
//  BookScanner
//
//  Created by David Riegel on 14.05.23.
//

import UIKit
import FirebaseAuth

class SettingsController: UIViewController {

    let userProfile: User
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    required init(profile: User) {
        userProfile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var signOutButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .systemRed
        btn.setTitle("Sign Out", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(logOut), for: .touchUpInside)
        return btn
    }()
    
    @objc func logOut() {
        let alertController = UIAlertController(title: "", message: "Are you sure that you want to sign out of your account?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { _ in
            _ = try? Auth.auth().signOut()
        }))
        
        present(alertController, animated: true)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func changedSetting() async {
        let homeController = (parent as? UINavigationController)?.viewControllers[0] as? HomeController
        homeController?.reloadWhenPopping = true
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Settings"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(signOutButton)
        signOutButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingRight: -20, height: 50)
    }
}
