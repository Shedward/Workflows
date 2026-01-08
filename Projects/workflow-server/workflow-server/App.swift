//
//  main.swift
//  workflow-server
//
//  Created by Vlad Maltsev on 08.01.2026.
//

import WorkflowServer

@main
struct App {
    static func main() async throws {
        let app = WorkflowServer.App()
        try await app.main()
    }
}

