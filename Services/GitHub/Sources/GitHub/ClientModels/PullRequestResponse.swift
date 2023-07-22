//
//  PullRequestResponse.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

struct PullRequestResponse: Decodable, RestBodyDecodable, Sendable {
    let id: Int
    let title: String
}
