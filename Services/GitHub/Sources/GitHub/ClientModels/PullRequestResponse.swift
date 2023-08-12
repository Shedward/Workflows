//
//  PullRequestResponse.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

struct PullRequestResponse: JSONDecodableBody {
    let id: Int
    let title: String
}
