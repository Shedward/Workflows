//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Core
import Foundation
import GoogleServices
import HHWorkflows
import os
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

        let workflowsConfigDir = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".workflows")

        let authRegistry = AuthRegistry()

        let oauthClientPath = workflowsConfigDir
            .appending(path: "google_cloud")
            .appending(path: "oauth_client.json")
        let googleCredentials = try GoogleOAuthCredentials.load(from: oauthClientPath)

        let googleTokenProvider = UserOAuthTokenProvider(
            credentials: googleCredentials,
            scopes: [
                "https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/spreadsheets"
            ],
            redirectURI: "https://127.0.0.1:8443/auth/google/callback"
        )
        await authRegistry.register(googleTokenProvider)

        let dependencies = DependenciesContainer([
            "googleDrive": GoogleDriveClient(tokenProvider: googleTokenProvider),
            "googleSheets": GoogleSheetsClient(tokenProvider: googleTokenProvider)
        ])

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
