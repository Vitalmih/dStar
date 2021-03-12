//
//  DetailViewController.swift
//  dStar
//
//  Created by Виталий on 09.03.2021.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {

    @IBOutlet weak var reposetoryName: UILabel!
   
    var detailRepositoryData = [Items]()
    
   
 
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemTeal
       
    }
    
}
