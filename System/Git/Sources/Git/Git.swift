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
        git = ProcessExecutable(command: "git")
    }
    
    init(mock: GitMock) {
        git = mock.executable
    }

    public func repository(at path: String) async throws -> Repository {
        let repositoryExecutable = git
            .workingDirectory(path)
            .errorOutput(to: nil)

        try await repositoryExecutable
            .run("rev-parse")
            .finished(.errorCodes([
                128: GitError.noGitRepositoryAtPath(path)
            ]))

        return Repository(git: repositoryExecutable, path: path)
    }
}

extension GitMock {
    func addRepository(workingDirectory: String, result: Result<Void, Error>) async {
        let filter = MockExecutionFilter(
            workingDirectory: .exact(workingDirectory),
            arguments: .exact(["rev-parse"])
        )
        
        await executable.addResult(filter: filter, result: result)
    }
    
    func addRepositoryNotFound(workingDirectory: String) async {
        let filter = MockExecutionFilter(
            workingDirectory: .exact(workingDirectory),
            arguments: .exact(["rev-parse"])
        )
        
        await executable.addResult(filter: filter, result: .success(.init(status: 128)))
    }
}
