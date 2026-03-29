//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Foundation
import GoogleServices
import HHWorkflows
import os
import Rest
import TestingWorkflows
import WorkflowEngine
import WorkflowServer

@main
enum App {
    static func main() async throws {
        Logger.enable(.workflow)
        Logger.enable(.network)

        let dependencies = DependenciesContainer()

        let workflowsConfigDir = FileManager.default.homeDirectoryForCurrentUser.appending(path: ".workflows")

        let oauthCredentials = try GoogleOAuthCredentials.load(
            from: workflowsConfigDir.appending(path: "google_cloud/oauth_client.json")
        )
        let googleProvider = UserOAuthTokenProvider(
            credentials: oauthCredentials,
            scopes: [
                "https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/spreadsheets"
            ],
            redirectURI: "http://localhost:8080/auth/google/callback"
        )

        let authRegistry = AuthRegistry()
        await authRegistry.register(googleProvider)

        let driveClient = GoogleDriveClient(tokenProvider: googleProvider)
        let sheetsClient = GoogleSheetsClient(tokenProvider: googleProvider)

        dependencies.set(driveClient, forKey: "googleDrive")
        dependencies.set(sheetsClient, forKey: "googleSheets")

        let storage = try await JSONFileWorkflowStorage(
            directory: workflowsConfigDir.appending(path: "instances")
        )

        let workflows = try await Workflows(storage: storage, dependencies: dependencies) {
            TestingWorkflows.workflows
            HHWorkflows.workflows
        }
        let app = WorkflowServer.App(workflows: workflows, authRegistry: authRegistry)
        try await app.main()
    }
}
