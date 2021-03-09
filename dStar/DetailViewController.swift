//
//  DetailViewController.swift
//  dStar
//
//  Created by Виталий on 09.03.2021.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var reposetoryName: UILabel!
   
    var items = [Items]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemPurple
        showRepoName()
    }
    
    func showRepoName() {
        for item in items {
            reposetoryName.text = item.name
        }
    }

   
}
