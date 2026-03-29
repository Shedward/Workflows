//
//  BranchingWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 21.03.2026.
//

import WorkflowEngine

struct GoLeft: Pass { }
struct GoRight: Pass { }

@DataBindable
struct BranchingWorkflow: Workflow {
    enum State: String, WorkflowState {
        case fork
        case left
        case right
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.fork)
        }

        on(.fork) {
            GoLeft.to(.left)
            GoRight.to(.right)
        }

        on(.left) {
            Finalize.toFinish()
        }

        on(.right) {
            Finalize.toFinish()
        }
    }
}
