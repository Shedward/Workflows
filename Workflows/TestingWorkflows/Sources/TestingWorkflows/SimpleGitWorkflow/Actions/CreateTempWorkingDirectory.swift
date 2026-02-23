//
//  CreateTempWorkingDirectory.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct CreateTempWorkingDirectory: Action {
    @Output var workingDirectory: URL

    func run() async throws {
        let fileManager = FileManager.default
        let tempFolder = fileManager.temporaryDirectory
            .appending(component: "workflows", directoryHint: .isDirectory)
            .appending(component: UUID().uuidString, directoryHint: .isDirectory)

        try fileManager.createDirectory(at: tempFolder, withIntermediateDirectories: true)

        workingDirectory = tempFolder
    }
}
