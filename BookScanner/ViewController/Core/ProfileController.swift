//
//  ProfileController.swift
//  BookScanner
//
//  Created by David Riegel on 09.05.23.
//

import UIKit
import SDWebImage

class ProfileController: UIViewController {
    
    let userProfile: User!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateData()
    }
    
    required init(profile: User) {
        userProfile = profile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "avatarPlaceholder")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var displaynameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Display name"
        lb.font = .systemFont(ofSize: 16, weight: .semibold)
        lb.numberOfLines = 1
        lb.textAlignment = .left
        lb.textColor = .label
        return lb
    }()
    
    var usernameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "@username"
        lb.font = .systemFont(ofSize: 16, weight: .regular)
        lb.numberOfLines = 1
        lb.textAlignment = .left
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateData() {
        if let avatarURL = userProfile.avatarURL {
            avatarImageView.sd_setImage(with: avatarURL)
        }
        
        displaynameLabel.text = userProfile.displayName
        usernameLabel.text = userProfile.username
    }
    
    func changedProfilePicture() {
        let homeController = (parent as? UINavigationController)?.viewControllers[0] as? HomeController
        homeController?.reloadWhenPopping = true
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = userProfile.username
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem?.tintColor = .label
        navigationItem.largeTitleDisplayMode = .never
        
        // TODO: Add views
    }
}
