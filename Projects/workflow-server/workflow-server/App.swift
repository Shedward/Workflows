//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import WorkflowEngine
import WorkflowServer
import TestingWorkflows
import HHWorkflows
import GoogleServices
import os

@main
struct App {
    static func main() async throws {
        Logger.enable(.workflow)
        let dependencies = DependenciesContainer()

        let credentials = try ServiceAccountCredentials.load(from: "/path/to/service-account.json")
        let tokenProvider = ServiceAccountTokenProvider(
            credentials: credentials,
            scopes: [
                "https://www.googleapis.com/auth/drive.file",
                "https://www.googleapis.com/auth/spreadsheets",
            ]
        )
        let driveClient = GoogleDriveClient(
            tokenProvider: tokenProvider,
            templateSpreadsheetId: "1V4VFXKHZSLltv_zYcD7i8WDMWPbVHrBvkkFM-3ZBx3M",
            decompositionFolderId: "<decomposition-folder-id>"
        )
        let sheetsClient = GoogleSheetsClient(tokenProvider: tokenProvider)

        dependencies.set(driveClient, forKey: "googleDrive")
        dependencies.set(sheetsClient, forKey: "googleSheets")

        let workflows = try await Workflows(dependencies: dependencies) {
            TestingWorkflows.workflows
            HHWorkflows.workflows
        }
        let app = WorkflowServer.App(workflows: workflows)
        try await app.main()
    }
}

