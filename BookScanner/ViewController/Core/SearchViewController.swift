//
//  SearchViewController.swift
//  BookScanner
//
//  Created by David Riegel on 11.05.23.
//

import UIKit

class SearchViewController: UIViewController {
    
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
    
    lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: ResultsViewController(profile: userProfile))
        sc.searchBar.delegate = self
        return sc
    }()
    
    func configureViewComponents() {
        self.definesPresentationContext = true
        view.backgroundColor = .backgroundColor
        title = "Search"
        
        navigationItem.searchController = searchController
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Task {
            guard let text = searchBar.text, !text.isEmpty else { return }
            
            guard let resultsController = searchController.searchResultsController as? ResultsViewController else { return }
            var userArray = try await DatabaseHandler.shared.searchUser(text.lowercased())
            
            if let index = userArray.firstIndex(where: { $0.username == userProfile.username }) {
                userArray.remove(at: index)
            }
            
            resultsController.userArray = userArray
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            guard let resultsController = searchController.searchResultsController as? ResultsViewController else { return }
            resultsController.userArray = [User]()
        }
    }
}

class ResultsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var userArray = [User]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
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
    
    lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(UserSearchCollectionViewCell.self, forCellWithReuseIdentifier: "UserSearchCollectionViewCell")
        view.backgroundColor = .backgroundColor
        view.dataSource = self
        view.delegate = self
        
        return view
    }()
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserSearchCollectionViewCell", for: indexPath) as! UserSearchCollectionViewCell
        
        let user = userArray[indexPath.row]
        
        cell.displaynameLabel.text = user.displayName
        cell.usernameLabel.text = "@" + user.username
        
        let following = userProfile.followingPath.contains(where: { $0.hasSuffix(user.uid) })
        let followsYou = user.followingPath.contains(where: { $0.hasSuffix(userProfile.uid) })
        
        if following || followsYou {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(systemName: "person.fill")?.withTintColor(.secondaryLabel)
            attachment.bounds = CGRect(x: 0, y: ((cell.followingStateLabel.font.capHeight - attachment.image!.size.height).rounded()) / 2, width: attachment.image!.size.width - 1, height: attachment.image!.size.height - 1)
            let attachmentString = NSAttributedString(attachment: attachment)
            let  text = NSMutableAttributedString(string: "")
            text.append(attachmentString)
            var followingString: NSAttributedString!
            
            if following && !followsYou {
                followingString = NSAttributedString(string: "Following")
            } else if !following && followsYou {
                followingString = NSAttributedString(string: "Follows you")
            } else if following && followsYou {
                followingString = NSAttributedString(string: "You follow each other")
            }
            else {
                followingString = NSAttributedString(string: "Unknown")
            }
            
            text.append(followingString)
            cell.followingStateLabel.attributedText = text
            cell.followingStateLabel.isHidden = false
            
            cell.imageView.image = UIImage(named: "avatarPlaceholder")
        }
        
        if let avatarURL = user.avatarURL {
            cell.imageView.sd_setImage(with: avatarURL)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height / 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        let profileController = ProfileController(profile: userArray[indexPath.row])
        
        self.presentingViewController?.navigationController?.pushViewController(profileController, animated: true)
    }
}
