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
    
    lazy var imagePickerController: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    lazy var avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "avatarPlaceholder")
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 10
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
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
    
    @objc func changeProfilePicture() {
        Task {
            guard userProfile.uid == (try await DatabaseHandler.shared.getCurrentUID()) else {
                return
            }
            
            let alertController = UIAlertController(title: "", message: "Do you want to change your profile picture?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            if userProfile.avatarURL != nil {
                alertController.addAction(UIAlertAction(title: "Remove current", style: .destructive, handler: { _ in
                    self.avatarImageView.image = UIImage(named: "avatarPlaceholder")
                    Task {
                        await DatabaseHandler.shared.resetProfilePicture(self.userProfile.uid)
                        self.changedProfilePicture()
                    }
                }))
            }
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                self.changedProfilePicture()
                
                self.present(self.imagePickerController, animated: true)
            }))
            
            present(alertController, animated: true)
        }
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
        
        view.addSubview(avatarImageView)
        avatarImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 50, paddingLeft: 20, width: 75, height: 75)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        avatarImageView.addGestureRecognizer(tap)
        
        if let avatarURL = userProfile.avatarURL {
            avatarImageView.sd_setImage(with: avatarURL)
        }
    }
}

extension ProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Task {
            guard let image = info[.editedImage] as? UIImage else { return }
            
            try await DatabaseHandler.shared.uploadProfilePicture(image, userProfile.uid)
            avatarImageView.image = image
            
            dismiss(animated: true)
        }
    }
}
