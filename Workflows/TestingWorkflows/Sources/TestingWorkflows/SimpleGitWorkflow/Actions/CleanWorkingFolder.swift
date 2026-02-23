//
//  CleanWorkingFolder.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct CleanWorkingFolder: Action {
    @Input var workingDirectory: URL

    func run() async throws {
        try FileManager.default.removeItem(at: workingDirectory)
    }
}
