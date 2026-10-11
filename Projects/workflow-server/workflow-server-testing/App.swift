//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core
import Foundation
import os
import TestingWorkflows
import WorkflowEngine
import WorkflowServer

@main
enum App {
    static func main() async {
        do {
            try await runServer()
        } catch {
            reportFatalAndExit(error)
        }
    }

    private static func runServer() async throws {
        Logger.enable(.workflow)

        let dependencies = DependenciesContainer()

        let workflowsConfigDir = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".workflows")

        let authRegistry = AuthRegistry()

        let storage = InMemoryWorkflowStorage()

        let config = Config(certificatesDirectory: workflowsConfigDir.appending(path: "certs"))

        let plugins = Plugins {
            WorkflowTransitionUpdatesPlugin()
        }

        let workflows = try await Workflows(
            storage: storage,
            dependencies: dependencies,
            validation: .strict,
            plugins: plugins
        ) {
            TestingWorkflows.workflows
        }

        let app = WorkflowServer.App(
            workflows: workflows,
            authRegistry: authRegistry,
            config: config,
            plugins: plugins
        )
        try await app.main()
    }
}
