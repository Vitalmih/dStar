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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var apiManager: RepositoriesNetworkManagerProtocol?
    private var paginationSearchString = ""
    private var isSearching = false
    private var repos = [Items]()
    private let searchBar = UISearchBar()
    var coreDataString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPurple
        apiManager?.delegate = self
        configureNavigationBar()
        configureSearchBar()
        configureTableView()
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
        loadResult()
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
        coreDataString = text
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
        
        let searchResultItem = SearchResultsModel(context: context)
            searchResultItem.searchWord = coreDataString

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
        
        repos.append(contentsOf: repositories.items)
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
            return repos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.Identifier) as! RepositoryCell
        if isSearching {
            let repoName = searchResults[indexPath.row].searchWord
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
            let historySearchRequest = searchResults[indexPath.row].searchWord
            let array = searchResults[indexPath.row].results?.allObjects as NSArray?
            
        
            for i in array! {
                print(i)
            }
            
            

            repos = []
            paginationSearchString = historySearchRequest!
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
            let request: NSFetchRequest<SearchResultsModel> = SearchResultsModel.fetchRequest()
            
            do {
                let results = try context.fetch(request)
                searchResults = results
                let repositories = results.compactMap { $0.results?.allObjects as? NSArray }
                
            } catch {
                print(error)
            }
        tableView.reloadData()
        }
}
