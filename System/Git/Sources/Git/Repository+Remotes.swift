//
//  Repository+Remotes.swift
//
//
//  Created by Vlad Maltsev on 23.01.2024.
//

import Foundation
import Prelude

extension Repository {
    
    public func remoteRefExists(_ ref: Ref) async throws -> Bool {
        try await git
            .run("ls-remote", "--exit-code", "--heads", "origin", ref.rawValue)
            .mapStatusCode([
                0: true,
                2: false
            ])
    }
}
