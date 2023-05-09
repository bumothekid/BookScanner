//
//  HomeController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit
import SDWebImage

class HomeController: UIViewController {
    
    var booksDict: [String: Book] = [String: Book]() {
        didSet {
            booksArray = Array(booksDict.values)
            collectionView.reloadData()
        }
    }
    var booksArray: [Book] = [Book]()
    var bookOrder: [String] = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            booksDict = try await BookHandler().getAllBooks()
            bookOrder = try await BookHandler().getBookOrder()
        }
    }
    
    lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(BookCollectionViewCell.self, forCellWithReuseIdentifier: "BookCollectionViewCell")
        view.backgroundColor = .backgroundColor
        view.dataSource = self
        view.delegate = self
        return view
    }()

    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "Your library"
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.backgroundColor = .backgroundColor
        
        view.addSubview(collectionView)
        collectionView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.rightAnchor)
    }
}

extension HomeController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookOrder.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCollectionViewCell", for: indexPath) as! BookCollectionViewCell
        
        let bookIsbn = bookOrder[indexPath.row]
        let book = booksDict[bookIsbn]!
        
        cell.titleLabel.text = book.title
        cell.authorLabel.text = book.authors?.first ?? "No authors found"
        cell.imageView.image = UIImage(named: "placeholderCover")
        if let coverURL = book.imageLinks?.thumbnail {
            cell.imageView.sd_setImage(with: URL(string: coverURL))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 40, height: view.frame.height / 8)
    }
}
