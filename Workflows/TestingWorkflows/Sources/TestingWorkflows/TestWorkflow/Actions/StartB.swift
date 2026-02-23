//
//  StartB.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

@DataBindable
struct StartB: Action {
    @Input var valueA: String
    @Output var valueB: String

    func run() async throws {
        valueB = valueA + "_suffix"
    }
}
