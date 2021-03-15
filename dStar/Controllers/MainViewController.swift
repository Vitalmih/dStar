//
//  MainViewController.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import UIKit
import CoreData
import PureLayout

final class MainViewController: UIViewController {
    
    private enum NavigationTitle: String {
        case Repositories
        case History
    }
    
    private let context: NSManagedObjectContext
    private let apiManager: RepositoriesNetworkManagerProtocol
    
    private var searchResults = [SearchResultsModel]()
    private var paginationSearchString = ""
    private var isSearching = false
    private var receivedRepositories = [Item]()
    private let searchBar = UISearchBar()
    private var searchWord = ""
    private let tableView = UITableView()
    private var currentPage = 1
    private var totalCountOfPages = 0
    
    var upperView: UIView = {
        let view = UIView()
        view.autoSetDimension(.height, toSize: 128)
        view.backgroundColor = .systemTeal
        return view
    }()
    
    init(context: NSManagedObjectContext, apiManager: RepositoriesNetworkManagerProtocol) {
        self.context = context
        self.apiManager = apiManager
        super.init(nibName: nil, bundle: nil)
        apiManager.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationBar()
        configureSearchBar()
        addSubViews()
        setupConstraints()
        configureTableView()
    }
    
    func addSubViews() {
        view.addSubview(upperView)
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        upperView.autoPinEdge(toSuperviewEdge: .left)
        upperView.autoPinEdge(toSuperviewEdge: .right)
        upperView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewSafeArea: .bottom)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)
        tableView.autoPinEdge(.top, to: .bottom, of: upperView, withOffset: 10)
    }
    
    private func configureTableView() {
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.Identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        setTableViewDelegates()
    }
    
    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureNavigationBar() {
        let navigation = navigationController?.navigationBar
        navigation?.prefersLargeTitles = true
        navigationItem.title = NavigationTitle.Repositories.rawValue
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(handleShowSearchBar))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleShowHistorySearch))
        navigation?.tintColor = .black
        navigation?.backgroundColor = .systemTeal
        navigation?.barTintColor = .systemTeal
        navigation?.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigation?.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
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
    
    private func search(shouldShow: Bool) {
        showSearchBarButton(shouldShow: !shouldShow)
        searchBar.showsCancelButton = shouldShow
        navigationItem.titleView = shouldShow ? searchBar : nil
    }
    
    private func saveToCoreData(items: [Item]) {
        let searchResultItem = SearchResultsModel(context: context)
        searchResultItem.searchWord = searchWord
        
        let results: [Repository] = items.map { [unowned context] item in
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
    }
    
    private func showDetails(with repository: Item) {
        let dvc = DetailViewController(with: repository)
        let nv = UINavigationController(rootViewController: dvc)
        nv.modalPresentationStyle = .fullScreen
        present(nv, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, buttonTitle: String, error: Error) {
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        searchWord = text.replacingOccurrences(of: " ", with: "+")
        paginationSearchString = searchWord
        apiManager.getRepositories(with: paginationSearchString, page: 1)
        receivedRepositories = []
        currentPage = 1
        searchBar.text = ""
        tableView.reloadData()
    }
}

//MARK: - RepositoriesNetworkManagerDelegate
extension MainViewController: RepositoriesNetworkManagerDelegate {
    func didGetRepositories(repositories: Repositories) {
        
        if currentPage == 1 {
            saveToCoreData(items: repositories.items)
            totalCountOfPages = repositories.totalCount
        }
        
        receivedRepositories.append(contentsOf: repositories.items)
        
        self.tableView.reloadData()
    }
    
    func didFailWithError(error: Error) {
        showAlert(title: "Error", buttonTitle: "Ok", error: error)
    }
}

//MARK: -  UITableViewDataSource, UITableViewDelegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearching ? searchResults.count : receivedRepositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.Identifier) as? RepositoryCell else { return UITableViewCell() }
        if isSearching {
            let searchWord = searchResults[indexPath.row].searchWord
            cell.setTitle(name: searchWord?.maxLength(length: 30) ?? "N/A")
        } else {
            let repository = receivedRepositories[indexPath.row]
            cell.setTitle(name: repository.name.maxLength(length: 30))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if currentPage <= totalCountOfPages {
            if indexPath.row == receivedRepositories.count - 3 {
                currentPage += 1
                apiManager.getRepositories(with: paginationSearchString, page: currentPage)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isSearching {
            isSearching = false
            currentPage = 1
            navigationItem.title = NavigationTitle.Repositories.rawValue
            let historySearchWordRequest = searchResults[indexPath.row].searchWord ?? ""
            let coreDataRepositoriesModel = searchResults[indexPath.row].results?.allObjects.compactMap {$0 as? Repository} ?? []
            receivedRepositories = []
            coreDataRepositoriesModel.forEach { item in
                let repositoryItem = Item(id: Int(item.id), nodeID: item.nodeID ?? "", name: item.name ?? "", fullName: item.fullName ?? "", owner: nil, url: item.url ?? "", starsCount: Int(item.starsCount))
                receivedRepositories.append(repositoryItem)
            }
            paginationSearchString = historySearchWordRequest
            tableView.reloadData()
        } else {
            let repository = receivedRepositories[indexPath.row]
            showDetails(with: repository)
        }
    }
}

//MARK: - Core Data Methods
extension MainViewController {
    func saveResult() {
        do {
            try context.save()
        } catch {
            showAlert(title: "Error", buttonTitle: "Ok", error: error)
        }
    }
    
    func loadResult() {
        let request: NSFetchRequest<SearchResultsModel> = SearchResultsModel.fetchRequest()
        do {
            searchResults = try context.fetch(request)
        } catch {
            showAlert(title: "Error", buttonTitle: "Ok", error: error)
        }
    }
}
