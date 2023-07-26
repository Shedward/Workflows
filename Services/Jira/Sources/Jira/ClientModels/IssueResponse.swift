//
//  IssueResponse.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import RestClient

struct IssueResponse: Codable, Sendable, RestBodyDecodable {
    let id: String
    let key: String
}
