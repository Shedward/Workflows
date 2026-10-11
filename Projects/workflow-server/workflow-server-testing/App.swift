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

        let config = try await Config.load()

        let plugins = Plugins {
            WorkflowTransitionUpdatesPlugin()
        }

        let workflows = try await Workflows(
            storage: InMemoryWorkflowStorage(),
            dependencies: DependenciesContainer(),
            validation: .strict,
            plugins: plugins
        ) {
            TestingWorkflows.workflows
        }

        let app = WorkflowServer.App(
            workflows: workflows,
            config: config,
            plugins: plugins
        )
        try await app.main()
    }
}
