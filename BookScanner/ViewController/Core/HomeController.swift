//
//  HomeController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import SDWebImage
import FirebaseAuth

class HomeController: UIViewController {
    
    var booksDict: [String: Book] = [String: Book]() {
        didSet {
            booksArray = Array(booksDict.values)
        }
    }
    var booksArray: [Book] = [Book]()
    var bookOrder: [String] = [String]()
    let userProfile: User

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            booksDict = try await BookHandler().getAllBooks()
            bookOrder = try await BookHandler().getBookOrder()
            updateData()
        }
    }
    
    required init(profile: User) {
        userProfile = profile
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: BOOK OF THE WEEK
    
    lazy var currentBookView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondaryBackgroundColor
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var currentBookCover: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "placeholderCover"))
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var currentBookTitleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Book Title"
//        lb.font = UIFont(name: "Times New Roman Bold Italic", size: 20.0)
        lb.font = .systemFont(ofSize: 20, weight: .semibold)
        lb.numberOfLines = 1
        lb.textAlignment = .center
        lb.textColor = .label
        lb.adjustsFontSizeToFitWidth = true
        lb.minimumScaleFactor = 0.2
        return lb
    }()
    
    lazy var currentBookAuthorLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Author"
//        lb.font = UIFont(name: "Times New Roman", size: 14.0)
        lb.font = .systemFont(ofSize: 12, weight: .medium)
        lb.textAlignment = .left
        lb.textColor = .label
        return lb
    }()
    
    lazy var currentBookPagesLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Page Count"
//        lb.font = UIFont(name: "Times New Roman", size: 12.0)
        lb.font = .systemFont(ofSize: 10, weight: .medium)
        lb.textAlignment = .left
        lb.textColor = .label
        return lb
    }()
    
    lazy var recentlyAddedLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Recently added"
        lb.font = .systemFont(ofSize: 24, weight: .bold)
        lb.textColor = .label
        return lb
    }()
    
    lazy var recentlyAddedStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var recentlyAddedScrollView: UIScrollView = {
        let view = UIScrollView()
        view.isScrollEnabled = true
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            
            let signInController = SignInController()
            signInController.hidesBottomBarWhenPushed = true
            signInController.navigationItem.hidesBackButton = true
            navigationController?.pushViewController(signInController, animated: false)
        }
        catch {
            
        }
    }
    
    @objc func pushProfileController() {
        let profileController = ProfileController(profile: userProfile)
        
        navigationController?.pushViewController(profileController, animated: true)
    }
    
    func updateData() {
        guard let lastBookIndex = bookOrder.last else { return }
        guard let lastBook = booksDict[lastBookIndex] else { return }
        
        currentBookCover.image = UIImage(named: "placeholderCover")
        if let bookCoverURL = lastBook.coverURL {
            currentBookCover.sd_setImage(with: URL(string: bookCoverURL))
        }
        
        currentBookTitleLabel.text = lastBook.title
        currentBookAuthorLabel.text = lastBook.authors?.last ?? "No authors found"
        currentBookPagesLabel.text = "Pages: Page count not found"
        
        if let bookPages = lastBook.pageCount {
            currentBookPagesLabel.text = "Pages: \(String(describing: bookPages))"
        }
    
        for subview in recentlyAddedStackView.arrangedSubviews {
            recentlyAddedStackView.removeArrangedSubview(subview)
        }
        
        for i in 0...19 {
            if i >= bookOrder.count { break }
            guard let book = booksDict[bookOrder.reversed()[i]] else { return }
            
            let bookView: UIView = {
                let view = UIView()
                view.backgroundColor = .secondaryBackgroundColor
                view.layer.cornerRadius = 15
                return view
            }()
            
            let bookCover: UIImageView = {
                let iv = UIImageView(image: UIImage(named: "placeholderCover"))
                iv.contentMode = .scaleAspectFit
                iv.clipsToBounds = true
                iv.layer.cornerRadius = 15
                iv.translatesAutoresizingMaskIntoConstraints = false
                return iv
            }()
            
            let bookTitleLabel: UILabel = {
                let lb = UILabel()
                lb.text = "\(book.title)"
                lb.textColor = .white
                lb.textAlignment = .left
                lb.layer.shadowColor = UIColor.black.cgColor
                lb.layer.shadowRadius = 3.0
                lb.layer.shadowOpacity = 1.0
                lb.layer.shadowOffset = CGSize(width: 0, height: 0)
                lb.numberOfLines = 2
                lb.minimumScaleFactor = 0.3
                lb.adjustsFontSizeToFitWidth = true
                lb.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                return lb
            }()
            
            bookView.anchor(width: 97, height: view.frame.height / 5.5)
            
            bookView.addSubview(bookCover)
            
            NSLayoutConstraint.activate([bookCover.centerYAnchor.constraint(equalTo: bookView.centerYAnchor), bookCover.centerXAnchor.constraint(equalTo: bookView.centerXAnchor), bookCover.heightAnchor.constraint(equalTo: bookView.heightAnchor), bookCover.widthAnchor.constraint(equalTo: bookView.widthAnchor)])
            
            if let bookCoverURL = book.coverURL {
                bookCover.sd_setImage(with: URL(string: bookCoverURL))
                bookCover.contentMode = .scaleAspectFill
                
            }
            else {
                bookView.addSubview(bookTitleLabel)
                bookTitleLabel.anchor(left: bookView.leftAnchor, bottom: bookView.bottomAnchor, right: bookView.rightAnchor, paddingLeft: 7.5, paddingBottom: -10, paddingRight: -7.5)
            }
            
            recentlyAddedStackView.addArrangedSubview(bookView)
        }
    }

    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Your library"
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person", withConfiguration: UIImage.SymbolConfiguration(weight: .semibold)), style: .plain, target: self, action: #selector(pushProfileController))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.square.fill"), style: .plain, target: self, action: #selector(logOut))
        
        navigationItem.rightBarButtonItem?.tintColor = .label
        navigationItem.leftBarButtonItem?.tintColor = .label
        
        view.addSubview(currentBookView)
        currentBookView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 30, paddingLeft: 20, paddingRight: -20, height: view.frame.height / 8)
        
        currentBookView.addSubview(currentBookCover)
        currentBookCover.anchor(left: currentBookView.leftAnchor, width: 70.5, height: 70.5)
        currentBookCover.centerYAnchor.constraint(equalTo: currentBookView.centerYAnchor).isActive = true
        
        currentBookView.addSubview(currentBookTitleLabel)
        currentBookTitleLabel.anchor(top: currentBookCover.topAnchor, left: currentBookCover.rightAnchor, right: currentBookView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingRight: -10)
        
        currentBookView.addSubview(currentBookAuthorLabel)
        currentBookAuthorLabel.anchor(top: currentBookTitleLabel.bottomAnchor, left: currentBookTitleLabel.leftAnchor, paddingTop: 5, paddingLeft: 0)
        
        currentBookView.addSubview(currentBookPagesLabel)
        currentBookPagesLabel.anchor(top: currentBookAuthorLabel.bottomAnchor, left: currentBookAuthorLabel.leftAnchor, right: currentBookView.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingRight: -10)
        
        view.addSubview(recentlyAddedLabel)
        recentlyAddedLabel.anchor(top: currentBookView.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: -20)
        
        view.addSubview(recentlyAddedScrollView)
        recentlyAddedScrollView.addSubview(recentlyAddedStackView)
        recentlyAddedScrollView.anchor(top: recentlyAddedLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 7.5, paddingLeft: 20)
        
        recentlyAddedStackView.leadingAnchor.constraint(equalTo: recentlyAddedScrollView.leadingAnchor).isActive = true
        recentlyAddedStackView.trailingAnchor.constraint(equalTo: recentlyAddedScrollView.trailingAnchor).isActive = true
        recentlyAddedStackView.topAnchor.constraint(equalTo: recentlyAddedScrollView.topAnchor).isActive = true
        recentlyAddedStackView.bottomAnchor.constraint(equalTo: recentlyAddedScrollView.bottomAnchor).isActive = true
        recentlyAddedStackView.heightAnchor.constraint(equalTo: recentlyAddedScrollView.heightAnchor).isActive = true
    }
}
