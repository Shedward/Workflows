//
//  UserResponse.swift
//
//
//  Created by Vladislav Maltsev on 12.08.2023.
//

import RestClient

struct UserResponse: Decodable, RestBodyDecodable, Sendable {
    let id: String
    let email: String
    let handle: String
}
