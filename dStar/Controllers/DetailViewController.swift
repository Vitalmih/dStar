//
//  DetailViewController.swift
//  dStar
//
//  Created by Виталий on 09.03.2021.
//

import UIKit
import CoreData
import PureLayout
import SafariServices

final class DetailViewController: UIViewController {
    
    var detailRepositoryData: Item
    
    lazy var avatar: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "avatar"))
        imageView.autoSetDimensions(to: CGSize(width: 128.0, height: 128.0))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 3.0
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = 64.0
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var repositoryName: UILabel = {
        let name = UILabel()
        name.autoSetDimension(.height, toSize: 60)
        name.layer.borderWidth = 1.0
        name.layer.borderColor = UIColor.lightGray.cgColor
        name.layer.cornerRadius = 16
        name.clipsToBounds = true
        name.backgroundColor = .lightText
        name.textColor = .black
        name.textAlignment = .center
        return name
    }()
    
    var starsCountLabel: UILabel = {
        let name = UILabel()
        name.autoSetDimension(.height, toSize: 30)
        name.textColor = .black
        name.textAlignment = .center
        return name
    }()
    
    var starsLabel: UILabel = {
        let name = UILabel()
        name.autoSetDimension(.height, toSize: 30)
        name.textColor = .black
        name.textAlignment = .left
        name.text = "Stars:"
        return name
    }()
    
    var searchButton: UIButton = {
        let button = UIButton()
        button.autoSetDimension(.height, toSize: 50)
        button.setTitle("View in github", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemTeal
        button.layer.cornerRadius = 16
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(searchButtnPressed), for: .touchUpInside)
        return button
    }()
    
    var upperView: UIView = {
        let view = UIView()
        view.autoSetDimension(.height, toSize: 128)
        view.backgroundColor = .systemTeal
        return view
    }()
    
    init(with repository: Item) {
        self.detailRepositoryData = repository
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        configureNavigationBar()
        fetchData()
    }
    
    @objc func searchButtnPressed() {
        if let url = URL(string: detailRepositoryData.url) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc =  SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    private func fetchData() {
        repositoryName.text = detailRepositoryData.name
        starsCountLabel.text =  String(detailRepositoryData.starsCount)
        avatar.downloaded(from: detailRepositoryData.owner?.avatarURL ?? "")
    }
    
    private func configureNavigationBar() {
        let navigation = navigationController?.navigationBar
        navigation?.prefersLargeTitles = true
        navigationItem.title = "Repository"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        navigation?.tintColor = .black
        navigation?.backgroundColor = .systemTeal
        navigation?.barTintColor = .systemTeal
        navigation?.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigation?.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    @objc func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addSubviews() {
        view.addSubview(upperView)
        view.addSubview(repositoryName)
        view.addSubview(starsLabel)
        view.addSubview(avatar)
        view.addSubview(searchButton)
        view.addSubview(starsCountLabel)
    }
    
    func setupConstraints() {
        avatar.autoAlignAxis(toSuperviewAxis: .vertical)
        avatar.autoPinEdge(.top, to: .bottom, of: upperView, withOffset: 25)
        starsLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 8.0)
        starsLabel.autoPinEdge(.top, to: .bottom, of: repositoryName, withOffset: 16.0)
        repositoryName.autoPinEdge(toSuperviewEdge: .left, withInset: 8.0)
        repositoryName.autoPinEdge(toSuperviewEdge: .right, withInset: 8.0)
        repositoryName.autoAlignAxis(toSuperviewAxis: .vertical)
        repositoryName.autoPinEdge(.top, to: .bottom, of: avatar, withOffset: 20)
        upperView.autoPinEdge(toSuperviewEdge: .left)
        upperView.autoPinEdge(toSuperviewEdge: .right)
        upperView.autoPinEdge(toSuperviewEdge: .top)
        searchButton.autoPinEdge(.top, to: .bottom, of: starsLabel, withOffset: 20)
        searchButton.autoPinEdge(toSuperviewEdge: .left, withInset: 8.0)
        searchButton.autoPinEdge(toSuperviewEdge: .right, withInset: 8.0)
        starsCountLabel.autoPinEdge(.left, to: .right, of: starsLabel, withOffset: 10)
        starsCountLabel.autoPinEdge(.top, to: .bottom, of: repositoryName, withOffset: 16)
    }
}
