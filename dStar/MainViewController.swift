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
    case Repository
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchResults = [SearchResultsModel]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var apiManager: RepositoriesNetworkManagerProtocol?
    private var paginationSearchString = ""
    private var isSearching = false
    private var receivedRepositories = [Items]()
    private let searchBar = UISearchBar()
    var searchWord = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        apiManager?.delegate = self
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.Repositories.rawValue
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleShowHistorySearch))
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .systemTeal
        navigationController?.navigationBar.barTintColor = .systemTeal
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
        loadResult()
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
        searchWord = text
        for char in text {
            if char == " " {
                searchString.append("+")
            } else {
                searchString.append(char)
            }
        }
        paginationSearchString = searchString
        apiManager?.getRepositories(with: searchString, page: 1)
        receivedRepositories = []
        searchString = ""
        searchBar.text = ""
        tableView.reloadData()
    }
}



//MARK: - RepositoriesNetworkManagerDelegate
extension MainViewController: RepositoriesNetworkManagerDelegate {
    func didGetRepositories(repositories: Repositories) {
        
        let searchResultItem = SearchResultsModel(context: context)
        searchResultItem.searchWord = searchWord
        
        let results: [Repository] = repositories.items.map { [unowned context] item in
            let repository = Repository(context: context)
            repository.id = Int64(item.id)
            repository.name = item.name
            repository.starsCount = Int64(item.starsCount)
            repository.nodeID = item.nodeID
            repository.url = item.url
            repository.fullName = item.fullName
            return repository
        }
        
        let searchModelResults = searchResultItem.mutableSetValue(forKey: #keyPath(SearchResultsModel.results))
        searchModelResults.addObjects(from: results)
        searchResultItem.results = searchModelResults
        saveResult()
        
        receivedRepositories.append(contentsOf: repositories.items)
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
        if isSearching {
            return searchResults.count
        } else {
            return receivedRepositories.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.Identifier) as! RepositoryCell
        if isSearching {
            let searchWord = searchResults[indexPath.row].searchWord
            cell.repoNameLabel.text = searchWord
            return cell
        } else {
            let repository = receivedRepositories[indexPath.row]
            cell.repoNameLabel.text = repository.name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var currentPage = 1
        if indexPath.row == receivedRepositories.count - 3 {
            currentPage += 1
            apiManager?.getRepositories(with: paginationSearchString, page: currentPage)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSearching {
            isSearching = false
            navigationItem.title = NavigationTitle.Repositories.rawValue
            let historySearchWordRequest = searchResults[indexPath.row].searchWord ?? ""
            let coreDataRepositoriesModel = searchResults[indexPath.row].results?.allObjects.compactMap { $0  as? Repository} ?? []
            receivedRepositories = []
            coreDataRepositoriesModel.forEach { item in
                let repositoryItem = Items(id: Int(item.id), nodeID: item.nodeID ?? "", name: item.name ?? "", fullName: item.fullName ?? "", owner: nil, url: item.url ?? "", starsCount: Int(item.starsCount))
                receivedRepositories.append(repositoryItem)
            }
            paginationSearchString = historySearchWordRequest
            tableView.reloadData()
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            vc.detailRepositoryData = receivedRepositories
    
            show(vc, sender: nil)
        }
    }
}

//MARK: - Core Data Methods
extension MainViewController {
    func saveResult() {
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    func loadResult() {
        let request: NSFetchRequest<SearchResultsModel> = SearchResultsModel.fetchRequest()
        do {
            searchResults = try context.fetch(request)
        } catch {
            print(error)
        }
    }
}
