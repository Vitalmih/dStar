//
//  RepositoryModel.swift
//  dStar
//
//  Created by Виталий on 06.03.2021.
//

import Foundation

struct Repositories: Codable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

struct Item: Codable {
    let id: Int
    let nodeID: String
    let name: String
    let fullName: String
    let owner: Owner?
    let url: String
    let starsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case nodeID = "node_id"
        case name
        case fullName = "full_name"
        case owner
        case url = "html_url"
        case starsCount = "stargazers_count"
    }
}

struct Owner: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let url: String

    enum CodingKeys: String, CodingKey {
        case login
        case id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case url
    }
}
