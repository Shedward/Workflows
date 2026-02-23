//
//  CommitChanges.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Foundation
import Git
import WorkflowEngine

@DataBindable
struct CommitChanges: Action {
    @Input var workingDirectory: URL

    func run() async throws {
        let repository = Git.Repository(path: .init(workingDirectory.path()))
        try await repository.add()
        try await repository.commit(message: "Added README.md")
    }
}
