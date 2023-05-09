//
//  ProfileController.swift
//  BookScanner
//
//  Created by David Riegel on 09.05.23.
//

import UIKit

class ProfileController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewComponents()
    }
    
    func configureViewComponents() {
        view.backgroundColor = .backgroundColor
        title = "David"
        
        navigationItem.largeTitleDisplayMode = .never
    }
}
