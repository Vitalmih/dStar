//
//  RepoCell.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit

class RepositoryCell: UITableViewCell {
    
    static let Identifier = "RepositoryCell"

    @IBOutlet weak var repoNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}