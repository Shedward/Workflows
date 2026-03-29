//
//  CycleErrorWorkflows.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Triggers: automaticCycleWithoutExit (error), cycleDetected (warning)

@DataBindable
struct AutomaticCycleWorkflow: Workflow {
    enum State: String, WorkflowState {
        case loopA
        case loopB
    }

    var transitions: Transitions {
        chainedAfterStart {
            GoNextStep.to(.loopA)
        }

        chainedAfter(.loopA) {
            GoNextStep.to(.loopB)
        }

        chainedAfter(.loopB) {
            GoNextStep.to(.loopA)
        }
    }
}

// MARK: - Triggers: ambiguousAutomaticTransitions (warning)

@DataBindable
struct AmbiguousAutomaticWorkflow: Workflow {
    enum State: String, WorkflowState {
        case pathA
        case pathB
    }

    var transitions: Transitions {
        chainedAfterStart {
            GoNextStep.to(.pathA)
        }

        chainedAfterStart {
            GoNextStep.to(.pathB)
        }

        on(.pathA) {
            Finalize.toFinish()
        }

        on(.pathB) {
            Finalize.toFinish()
        }
    }
}
