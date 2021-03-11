//
//  MainViewController.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit
import CoreData

enum NavigationTitle: String {
    case Repositories
    case History
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults = [SearchResultsModel]()
    var resultRepo = [Repository]()
    var searchResultItem: SearchResultsModel?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var apiManager: RepositoriesNetworkManagerProtocol?
    private var historySearchRequests: [String] = []
    private var paginationSearchString = ""
    private var searchingByName: [String] = []
    private var isSearching = false
    private var repos = [Items]()
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        apiManager?.delegate = self
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
        
        loadResult()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.Repositories.rawValue
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleShowHistorySearch))
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .systemPurple
        navigationController?.navigationBar.barTintColor = .systemPurple
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
    }
    
    @objc func handleShowSearchBar() {
        search(shouldShow: true)
        navigationItem.title = NavigationTitle.Repositories.rawValue
        searchBar.becomeFirstResponder()
        isSearching = false
        tableView.reloadData()
    }
    
    @objc func handleShowHistorySearch() {
        search(shouldShow: false)
        navigationItem.title = NavigationTitle.History.rawValue
        isSearching = true
        tableView.reloadData()
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
}

//MARK: - UISearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search(shouldShow: false)
        self.searchBar.text = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        var searchString = ""
        guard let text = searchBar.text else { return }
        historySearchRequests.append(text)
        
        for char in text {
            if char == " " {
                searchString.append("+")
            } else {
                searchString.append(char)
            }
        }
        paginationSearchString = searchString
        apiManager?.getRepositories(with: searchString, page: 1)
        repos = []
        searchString = ""
        searchBar.text = ""
        tableView.reloadData()
    }
}

//MARK: - RepositoriesNetworkManagerDelegate
extension MainViewController: RepositoriesNetworkManagerDelegate {
    func didGetRepositories(repositories: Repositories) {
        
        searchResultItem?.searchWord = paginationSearchString
        searchResultItem?.results?.setValue(repositories, forKey: "results")
        
        
//        let newRepo = Repository(context: context)
        for repo in repositories.items {
            self.repos.append(repo)
//            newRepo.id = Int64(repo.id)
//            newRepo.name = repo.name
//            newRepo.starsCount = Int64(repo.starsCount)
//            newRepo.parentSearchWord = searchResultItem
        }
//        resultRepo.append(newRepo)
        self.tableView.reloadData()
        saveResult()
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
        if isSearching {
            return historySearchRequests.count
        } else {
            return repos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.Identifier) as! RepositoryCell
        if isSearching {
            let repoName = historySearchRequests[indexPath.row]
            cell.repoNameLabel.text = repoName
            return cell
        } else {
            let repo = repos[indexPath.row]
            cell.repoNameLabel.text = repo.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var currentPage = 1
        if indexPath.row == repos.count - 3 {
            currentPage += 1
            apiManager?.getRepositories(with: paginationSearchString, page: currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            isSearching = false
            navigationItem.title = NavigationTitle.Repositories.rawValue
            let historySearchRequest = historySearchRequests[indexPath.row]
            repos = []
            paginationSearchString = historySearchRequest
            apiManager?.getRepositories(with: historySearchRequest, page: 1)
            tableView.reloadData()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.items = repos
            show(vc, sender: nil)
        }
    }
}

extension MainViewController {
    
    func saveResult() {
        do {
            try context.save()
        } catch {
           print(error)
        }
    }
    
    func loadResult() {
        let request: NSFetchRequest<Repository> = Repository.fetchRequest()
        
        do {
            resultRepo = try context.fetch(request)
           
            for repo in resultRepo {
                print(repo.name)
            }
        } catch {
            print(error)
        }
    }
}
