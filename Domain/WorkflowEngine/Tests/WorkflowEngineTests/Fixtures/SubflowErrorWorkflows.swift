//
//  SubflowErrorWorkflows.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Helper: Subflow that requires input

@DataBindable
struct NeedySubflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    @Input var requiredData: String

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.done)
        }

        on(.done) {
            Finalize.toFinish()
        }
    }
}

// MARK: - Triggers: unsatisfiedSubflowInput

@DataBindable
struct UnsatisfiedSubflowInputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case beforeSubflow
        case afterSubflow
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.beforeSubflow)
        }

        on(.beforeSubflow) {
            NeedySubflow.to(.afterSubflow)
        }

        on(.afterSubflow) {
            Finalize.toFinish()
        }
    }
}

// MARK: - Triggers: circularSubflow

@DataBindable
struct CircularAlpha: Workflow {
    enum State: String, WorkflowState {
        case sub
    }

    var transitions: Transitions {
        onStart {
            CircularBeta.to(.sub)
        }

        on(.sub) {
            Finalize.toFinish()
        }
    }
}

@DataBindable
struct CircularBeta: Workflow {
    enum State: String, WorkflowState {
        case sub
    }

    var transitions: Transitions {
        onStart {
            CircularAlpha.to(.sub)
        }

        on(.sub) {
            Finalize.toFinish()
        }
    }
}
