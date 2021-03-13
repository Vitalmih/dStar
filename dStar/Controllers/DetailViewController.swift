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

class DetailViewController: UIViewController {
    
    var detailRepositoryData: Items?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setupConstraints()
        configureNavigationBar()
        fetchData()
    }
    
    @objc func searchButtnPressed() {
        if let url = URL(string: detailRepositoryData?.url ?? "") {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            let vc =  SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    private func fetchData() {
        repositoryName.text = detailRepositoryData?.name
        starsCountLabel.text =  String(detailRepositoryData!.starsCount)
        avatar.downloaded(from: detailRepositoryData?.owner?.avatarURL ?? "")
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.Repository.rawValue
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancelButton))
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .systemTeal
        navigationController?.navigationBar.barTintColor = .systemTeal
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    @objc func handleCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addSubviews() {
        self.view.addSubview(upperView)
        self.view.addSubview(repositoryName)
        self.view.addSubview(starsLabel)
        self.view.addSubview(avatar)
        self.view.addSubview(searchButton)
        self.view.addSubview(starsCountLabel)
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
