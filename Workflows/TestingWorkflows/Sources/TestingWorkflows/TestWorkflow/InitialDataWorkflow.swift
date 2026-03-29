//
//  InitialDataWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 21.03.2026.
//

import WorkflowEngine

@DataBindable
struct ReadInitialData: Action {
    @Input var greeting: String
    @Output var result: String

    func run() {
        result = greeting + "_processed"
    }
}

@DataBindable
struct InitialDataWorkflow: Workflow {
    enum State: String, WorkflowState {
        case processed
    }

    @Input var greeting: String

    var transitions: Transitions {
        onStart {
            ReadInitialData.to(.processed)
        }

        on(.processed) {
            Finalize.toFinish()
        }
    }
}
