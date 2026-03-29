//
//  FailingWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 21.03.2026.
//

import Core
import WorkflowEngine

@DataBindable
struct FailAction: Action {
    func run() throws {
        throw Failure("Intentional test failure")
    }
}

@DataBindable
struct FailingWorkflow: Workflow {
    enum State: String, WorkflowState {
        case shouldFail
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.shouldFail)
        }

        on(.shouldFail) {
            FailAction.toFinish()
        }
    }
}
