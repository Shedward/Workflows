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

    enum CodingKeys: CodingKey {
        case id
        case owner
        case name
        case description
    }

    enum OwnerCodingKeys: CodingKey {
        case login
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)

        let ownerContainer = try container.nestedContainer(keyedBy: OwnerCodingKeys.self, forKey: .owner)
        self.owner = try ownerContainer.decode(String.self, forKey: .login)

        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
    }
}
