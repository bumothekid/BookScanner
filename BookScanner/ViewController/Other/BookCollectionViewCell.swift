//
//  BookCollectionViewCell.swift
//  BookScanner
//
//  Created by David Riegel on 08.05.23.
//

import UIKit

//class BookCollectionViewCell: UICollectionViewCell {
//    static let identifier = "BookCollectionViewCell"
//
//    var imageView: UIImageView = {
//        let iv = UIImageView()
//        iv.image = UIImage(named: "placeholderCover")
//        iv.contentMode = .scaleAspectFit
//        iv.clipsToBounds = true
//        return iv
//    }()
//
//    var titleLabel: UILabel = {
//        let lb = UILabel()
//        lb.text = "Title"
//        lb.font = UIFont(name: "Times New Roman Bold Italic", size: 24.0)
//        lb.textAlignment = .left
//        lb.textColor = .label
//        lb.adjustsFontSizeToFitWidth = true
//        lb.minimumScaleFactor = 0.2
//        return lb
//    }()
//
//    var authorLabel: UILabel = {
//        let lb = UILabel()
//        lb.text = "Author"
//        lb.font = UIFont(name: "Times New Roman", size: 15.0)
//        lb.textAlignment = .left
//        lb.textColor = .label
//        return lb
//    }()
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//    }
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        contentView.backgroundColor = .secondaryBackgroundColor
//        contentView.layer.cornerRadius = 15
//
//        contentView.addSubview(imageView)
//        imageView.anchor(left: contentView.leftAnchor, width: contentView.frame.height / 1.5, height: contentView.frame.height / 1.5)
//        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//
//        contentView.addSubview(titleLabel)
//        titleLabel.anchor(left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 0, paddingRight: -10)
//        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
//
//        contentView.addSubview(authorLabel)
//        authorLabel.anchor(left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 0)
//        authorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10).isActive = true
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class BookCollectionViewCell: UICollectionViewCell {
    static let identifier = "BookCollectionViewCell"
    
    var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "placeholderCover")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Title"
        lb.font = UIFont(name: "Times New Roman Bold Italic", size: 16.0)
        lb.numberOfLines = 0
        lb.textAlignment = .left
        lb.textColor = .label
        lb.adjustsFontSizeToFitWidth = true
        lb.minimumScaleFactor = 0.2
        return lb
    }()
    
    var authorLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Author"
        lb.font = UIFont(name: "Times New Roman", size: 12.0)
        lb.textAlignment = .left
        lb.textColor = .label
        return lb
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .secondaryBackgroundColor
        contentView.layer.cornerRadius = 15
        
        contentView.addSubview(imageView)
        imageView.anchor(left: contentView.leftAnchor, width: contentView.frame.height / 1.5, height: contentView.frame.height / 1.5)
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        contentView.addSubview(titleLabel)
        titleLabel.anchor(left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 0, paddingRight: -10)
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
        
        contentView.addSubview(authorLabel)
        authorLabel.anchor(left: imageView.rightAnchor, right: contentView.safeAreaLayoutGuide.rightAnchor, paddingLeft: 0)
        authorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
