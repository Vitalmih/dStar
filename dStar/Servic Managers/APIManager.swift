//
//  APIManager.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import Foundation
import Alamofire

protocol RepositoriesNetworkManagerProtocol {
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

class APIManager: RepositoriesNetworkManagerProtocol {
    
    var delegate: RepositoriesNetworkManagerDelegate?
    private let baseURL = "https://api.github.com/search/repositories?"
    
    func getRepositories(with word: String, page: Int = 1) {
        performRequest(pageNumber: page, word, sortBy: .star)
    }
    
    private func performRequest(pageNumber: Int, perPage: Int = 30, _ word: String, sortBy: SortType) {
        let url = "\(baseURL)sort=\(SortType.self)&page=\(pageNumber)&per_page=\(perPage)&q=\(word)"
        
        AF.request(url, method: .get).responseJSON { response in
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
