//
//  HomeController.swift
//  BookScanner
//
//  Created by David Riegel on 07.05.23.
//

import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewComponents()
    }

    func configureViewComponents() {
        view.backgroundColor = .purple
        title = "Shelf"
        
        navigationItem.largeTitleDisplayMode = .never
        
    }
}

