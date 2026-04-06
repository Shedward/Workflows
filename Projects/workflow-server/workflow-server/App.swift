//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core
import Foundation
import HHWorkflows
import os
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

        let certsPath = workflowsConfigDir.appending(path: "certs")
        let config = Config(
            tlsCertificatePath: certsPath.appending(path: "localhost+2.pem").path(),
            tlsPrivateKeyPath: certsPath.appending(path: "localhost+2-key.pem").path()
        )

        let workflows = try await Workflows(
            storage: storage,
            dependencies: dependencies,
            validation: .strict
        ) {
            HHWorkflows.workflows
        }

        let app = WorkflowServer.App(
            workflows: workflows,
            authRegistry: authRegistry,
            config: config
        )
        try await app.main()
    }
}
