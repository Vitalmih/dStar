//
//  APIManager.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import Foundation
import Alamofire

protocol RepositoriesNetworkManagerProtocol: AnyObject {
    var delegate: RepositoriesNetworkManagerDelegate? { get set }
    
    func getRepositories(with word: String, page: Int)
}

protocol RepositoriesNetworkManagerDelegate {
    
    func didGetRepositories(repositories: Repositories)
    func didFailWithError(error: Error)
}

enum SortType: String {
    case star
    case forks
    case helpWantedIssues = "help-wanted-issues"
}

final class APIManager: RepositoriesNetworkManagerProtocol {
    
    var delegate: RepositoriesNetworkManagerDelegate?
    private let baseURL = "https://api.github.com/search/repositories?"
    
    func getRepositories(with word: String, page: Int = 1) {
        performRequest(pageNumber: page, word: word, sortBy: SortType.star)
    }
    
    private func performRequest(pageNumber: Int, perPage: Int = 30, word: String, sortBy: SortType) {
        let urlString = "\(baseURL)sort=\(SortType.self)&page=\(pageNumber)&per_page=\(perPage)&q=\(word)"
        print(urlString)
        AF.request(urlString, method: .get).responseJSON { response in
            switch response.result {
            case .success:
                let decoder = JSONDecoder()
                guard let data = response.data else { return }
                do {
                    let decodedData = try decoder.decode(Repositories.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.didGetRepositories(repositories: decodedData)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.didFailWithError(error: error)
                    }
                }
            case .failure(let error):
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
}
