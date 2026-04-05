//
//  ProvidedWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 03.04.2026.
//

import WorkflowEngine

@DataBindable
struct TestProvider: WorkflowStartProvider {
    func starting() async throws -> [WorkflowStart] {
        [
            WorkflowStart(title: "First item")
                .input("greeting", to: "hello"),
            WorkflowStart(title: "Second item")
                .input("greeting", to: "world"),
        ]
    }
}

@DataBindable
struct ProvidedWorkflow: Workflow {
    enum State: String, WorkflowState {
        case processed
    }

    @Input var greeting: String

    var providers: [any WorkflowStartProvider] {
        TestProvider()
        ManualProvider()
    }

    var transitions: Transitions {
        onStart {
            ReadInitialData.to(.processed)
        }

        on(.processed) {
            Finalize.toFinish()
        }
    }
}
