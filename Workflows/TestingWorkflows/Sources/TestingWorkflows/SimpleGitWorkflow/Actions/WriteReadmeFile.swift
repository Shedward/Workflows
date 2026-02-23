//
//  WriteReadmeFile.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Foundation
import WorkflowEngine

@DataBindable
struct WriteReadmeFile: Action {
    @Input var workingDirectory: URL

    func run() async throws {
        let readmePath = workingDirectory
            .appending(component: "README.md", directoryHint: .notDirectory)

        let readmeContent = """
        This is testing readme
        """

        guard let data = readmeContent.data(using: .utf8) else {
            throw Failure("Failed to encode content")
        }

        try data.write(to: readmePath)
    }
}
