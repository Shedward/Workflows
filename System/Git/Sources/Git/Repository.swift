//
//  Repository.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 29.07.2023.
//

import Prelude
import Executable
import Foundation

public struct Repository {
    private let git: Executable

    init(git: Executable) {
        self.git = git
    }

    public func currentBranch() async throws -> Ref {
        let output = try await git.runForOutput("rev-parse", "--abbrev-ref", "HEAD")
        let branchName = output.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !branchName.isEmpty else {
            throw Failure("Unexpected empty branch name")
        }

        return Ref(rawValue: branchName)
    }
}
