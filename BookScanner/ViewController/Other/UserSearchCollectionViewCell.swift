//
//  UserSearchCollectionViewCell.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import UIKit

class UserSearchCollectionViewCell: UICollectionViewCell {
    static let identifier = "UserSearchCollectionViewCell"
    
    var imageView: UIImageView = {
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
        lb.font = .systemFont(ofSize: 15, weight: .regular)
        lb.numberOfLines = 1
        lb.textAlignment = .left
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    lazy var followingStateLabel: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.font = .systemFont(ofSize: 14, weight: .regular)
        lb.numberOfLines = 1
        lb.textAlignment = .left
        lb.textColor = .secondaryLabel
        return lb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.anchor(left: contentView.leftAnchor, paddingLeft: 20, width: contentView.frame.height / 1.5, height: contentView.frame.height / 1.5)
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.layer.cornerRadius = (contentView.frame.height / 1.5) / 2
        
        contentView.addSubview(displaynameLabel)
        displaynameLabel.anchor(top: imageView.topAnchor, left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 10, paddingRight: -10)
        
        contentView.addSubview(usernameLabel)
        usernameLabel.anchor(top: displaynameLabel.bottomAnchor, left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 0.5, paddingLeft: 10, paddingRight: -10)
        
        contentView.addSubview(followingStateLabel)
        followingStateLabel.anchor(top: usernameLabel.bottomAnchor, left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingTop: 1, paddingLeft: 10, paddingRight: -10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
