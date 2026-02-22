//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import WorkflowEngine
import WorkflowServer

@main
struct App {
    static func main() async throws {
        let dependencies = DependenciesContainer()
        dependencies.set((), forKey: "unexpectedDependency")

        let workflows = try await Workflows(
            dependencies: dependencies,
            TestWorkflow()
        )
        let app = WorkflowServer.App(workflows: workflows)
        try await app.main()
    }
}
