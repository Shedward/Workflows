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
    private let git: Executable
    
    public let directory: FileItem

    init(git: Executable, directory: FileItem) {
        self.git = git
        self.directory = directory
    }

    public func currentBranch() async throws -> Ref {
        let output = try await git.runForOutput("rev-parse", "--abbrev-ref", "HEAD")
        let branchName = output.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !branchName.isEmpty else {
            throw Failure("Unexpected empty branch name")
        }

        return Ref(rawValue: branchName)
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
