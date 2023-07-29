//
//  GitRepository.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation
import Executable

public struct Git {
    private let git: Executable

    public init() {
        git = Executable(command: "git")
    }

    public func repository(at path: String) async throws -> Repository {
        let repositoryExecutable = git
            .workingDirectory(path)
            .errorOutput(to: nil)

        try await repositoryExecutable
            .errorCodes([
                128: GitError.noGitRepositoryAtPath(path)
            ])
            .run("rev-parse")

        return Repository(git: repositoryExecutable)
    }
}
