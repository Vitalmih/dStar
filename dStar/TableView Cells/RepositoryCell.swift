//
//  RepoCell.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit
import PureLayout

final class RepositoryCell: UITableViewCell {
    
    static let Identifier = "RepositoryCell"
    private let repositoryName = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(repositoryName)
        configureTitleLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(name: String) {
        self.repositoryName.text = name
    }
    
    private func configureTitleLabel() {
        let nameInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 8)
        repositoryName.autoPinEdgesToSuperviewEdges(with: nameInsets, excludingEdge: .bottom)
    }
}
