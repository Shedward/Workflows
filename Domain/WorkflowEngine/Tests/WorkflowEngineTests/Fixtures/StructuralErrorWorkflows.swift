//
//  StructuralErrorWorkflows.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Triggers: unreachableFinish, deadEndState

@DataBindable
struct UnreachableFinishWorkflow: Workflow {
    enum State: String, WorkflowState {
        case stateA = "a"
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.stateA)
        }
    }
}

// MARK: - Triggers: unreachableState (warning)

@DataBindable
struct UnreachableStateWorkflow: Workflow {
    enum State: String, WorkflowState {
        case stateA = "a"
        case phantom
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.stateA)
        }

        on(.stateA) {
            Finalize.toFinish()
        }
    }
}
