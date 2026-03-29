//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Foundation
import os
import TestingWorkflows
import WorkflowEngine
import WorkflowServer

@main
enum App {
    static func main() async throws {
        Logger.enable(.workflow)

        let dependencies = DependenciesContainer()

        let workflowsConfigDir = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".workflows")

        let authRegistry = AuthRegistry()

        let storage = try await JSONFileWorkflowStorage(
            directory: workflowsConfigDir.appending(path: "instances")
        )

        let workflows = try await Workflows(storage: storage, dependencies: dependencies, validation: .strict) {
            TestingWorkflows.workflows
        }
        let app = WorkflowServer.App(workflows: workflows, authRegistry: authRegistry)
        try await app.main()
    }
}
