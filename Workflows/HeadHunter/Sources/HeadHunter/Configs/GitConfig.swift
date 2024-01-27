//
//  MainRepositoryConfig.swift
//
//
//  Created by v.maltsev on 06.09.2023.
//

import Foundation
import Prelude

public struct GitConfig: Decodable {
    public let repos: [RepoDetails]
    
    public init(repos: [RepoDetails]) {
        self.repos = repos
    }
    
    public func repo(_ name: Repo) throws -> RepoDetails {
        guard let details = repos.first(where: { $0.name == name }) else {
            throw Failure("Repository with \(name) not found in git.json")
        }
        
        return details
    }
}
