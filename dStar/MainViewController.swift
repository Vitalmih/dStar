//
//  MainViewController.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var apiManager: RepositoriesNetworkManagerProtocol?
    private let cellReuseIdentifier = "RepoCell"
    private var historyRequests: [String] = []
    private var currentRequest = "layer"
    private var currentPage = 1
    var repos = [Items]()
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    private func configureTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        apiManager?.delegate = self
        configureNavigationBar()
        configureSearchBar()
    }
    
    private func configureNavigationBar() {
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Repositories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemPurple
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func configureSearchBar() {
        
        searchBar.searchTextField.leftView?.tintColor = .black
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.barStyle = .black
        searchBar.searchTextField.textColor = .black
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search here...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        showSearchBarButton(shouldShow: true)
        
    }
    
    private func showSearchBarButton(shouldShow: Bool) {
        
        if shouldShow {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func search(shouldShow: Bool ) {
        
        showSearchBarButton(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }
    
    @objc func handleShowSearchBar() {
        search(shouldShow: true)
        searchBar.becomeFirstResponder()
    }
}

//MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        search(shouldShow: false)
        self.searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text else { return }
        self.historyRequests.append(text)
        apiManager?.getRepositories(with: text, page: 1)
        self.repos = []
        tableView.reloadData()
    }
}

//MARK: - RepositoriesNetworkManagerDelegate
extension MainViewController: RepositoriesNetworkManagerDelegate {
    func didGetRepositories(repositories: Repositories) {
        
        for repo in repositories.items {
            self.repos.append(repo)
        }
        self.tableView.reloadData()
    }
    
    func didFailWithError(error: Error) {
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: -  UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! RepoCell
        let repo = repos[indexPath.row]
        cell.repoNameLabel.text = repo.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == repos.count - 3 {
            currentPage += 1
            apiManager?.getRepositories(with: currentRequest, page: currentPage)
        }
    }
}
