//
//  RepoResponse.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

struct RepoResponse: Decodable, RestBodyDecodable, Sendable {
    let id: Int
    let owner: String
    let name: String
    let description: String
}
