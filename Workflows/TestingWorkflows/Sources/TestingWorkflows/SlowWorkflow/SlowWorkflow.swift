//
//  SlowWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 22.03.2026.
//

import WorkflowEngine

@DataBindable
struct SlowWorkflow: Workflow {
    enum State: String, WorkflowState {
        case processing
    }

    var transitions: Transitions {
        onStart {
            SlowAction.to(.processing)
        }

        on(.processing) {
            QuickFinish.toFinish()
        }
    }
}

/// An automatic variant where the slow action runs inline on start.
@DataBindable
struct AutomaticSlowWorkflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    var transitions: Transitions {
        chainedAfterStart {
            SlowAction.to(.done)
            QuickFinish.toFinish()
        }
    }
}
