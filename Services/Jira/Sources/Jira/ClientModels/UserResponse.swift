//
//  UserResponse.swift
//  Created by Vladislav Maltsev on 26.07.2023.
//

import Foundation
import RestClient

struct UserResponse: Codable, Sendable, RestBodyDecodable {
    let key: String
    let name: String
    let emailAddress: String
    let displayName: String
}
