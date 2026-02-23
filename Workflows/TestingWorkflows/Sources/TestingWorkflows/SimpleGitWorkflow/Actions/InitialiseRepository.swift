//
//  InitialiseRepository.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Foundation
import Git
import WorkflowEngine

@DataBindable
struct InitialiseRepository: Action {
    @Input var workingDirectory: URL

    func run() async throws {
        let repository = Git.Repository(path: .init(workingDirectory.path()))
        try await repository.initialise()
    }
}
