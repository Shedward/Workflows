//
//  GitRepository.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Foundation
import Executable
import FileSystem

public struct Git {
    internal let git: Executable

    public init() {
        git = ProcessExecutable(command: "git")
    }
    
    public init(mock: GitMock) {
        git = mock.executable
    }

    public func repository(at directory: FileItem) async throws -> Repository {
        let repositoryExecutable = git
            .workingDirectory(directory.path.string)
            .errorOutput(to: nil)

        try await repositoryExecutable
            .run("rev-parse")
            .finished(.errorCodes([
                128: GitError.noGitRepositoryAtPath(directory.path.string)
            ]))

        return Repository(git: repositoryExecutable, directory: directory)
    }
    
    public func clone(_ repoUrl: String, to directory: FileItem) async throws -> Repository {
        try await git
            .run("clone", repoUrl, directory.path.string)
            .finished()
        
        let repositoryExecutable = git
            .workingDirectory(directory.path.string)

        return Repository(git: repositoryExecutable, directory: directory)
    }
    
    public func exists(in directory: FileItem) async throws -> Bool {
        let repositoryExecutable = git
            .workingDirectory(directory.path.string)
            .errorOutput(to: nil)

        let result = try await repositoryExecutable
            .run("rev-parse")
        
        if result.isSuccessful {
            return true
        } else if result.status == 128 {
            return false
        } else {
            throw GitError.unexpectedStatusCode(result.status)
        }
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
