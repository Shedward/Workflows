//
//  StartA.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

@DataBindable
struct StartA: Action {
    @Output var valueA: String

    func run() async throws {
        valueA = "Returned"
    }
}
