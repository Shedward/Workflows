//
//  User.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

import RestClient

struct UserResponse: Decodable, RestBodyDecodable, Sendable {
    let id: Int
    let login: String
    let name: String
}
