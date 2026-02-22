//
//  Repository.swift
//  Git
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Core
import Subprocess
import System

public struct Repository {
    let path: FilePath
    let client: GitClient

    public init(path: FilePath) {
        self.path = path
        self.client = GitClient(workingPath: path)
    }

    public func assertExists() async throws {
        guard try await exists() else {
            throw Failure("Repository \(path) does not exists")
        }
    }

    public func exists() async throws -> Bool {
        let result = try await client.run("rev-parse", arguments: "--is-inside-work-tree")
        return result.standardOutput == "true\n"
    }
}
