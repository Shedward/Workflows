//
//  Repository.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Prelude
import Executable
import Foundation
import FileSystem

public struct Repository {
    internal let git: Executable
    
    public let directory: FileItem

    init(git: Executable, directory: FileItem) {
        self.git = git
        self.directory = directory
    }

    public func push() async throws {
        try await git.run("push").finished()
    }
    
    public func fetch() async throws {
        try await git.run("fetch").finished()
    }
    
    public func pull() async throws {
        try await git.run("pull").finished()
    }
}

extension GitMock {
    func addCurrentBranch(workingDirectory: String, ref: Result<String, Error>) async {
        let filter = MockExecutionFilter(
            workingDirectory: .exact(workingDirectory),
            arguments: .exact(["rev-parse", "--abbrev-ref", "HEAD"])
        )
        await executable.addOutput(filter: filter, result: ref)
    }
    
    func addPush(workingDirectory: String, result: Result<Void, Error>) async {
        let filter = MockExecutionFilter(
            workingDirectory: .exact(workingDirectory),
            arguments: .exact(["push"])
        )
        
        await executable.addResult(filter: filter, result: result)
    }
}
