//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import Workflow
import WorkflowServer

@main
struct App {
    static func main() async throws {
        let workflows = try await Workflows(
            TestWorkflow()
        )
        let app = WorkflowServer.App(workflows: workflows)
        try await app.main()
    }
}

