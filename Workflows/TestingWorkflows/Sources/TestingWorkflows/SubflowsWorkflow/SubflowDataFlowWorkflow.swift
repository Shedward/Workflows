//
//  SubflowDataFlowWorkflow.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Subflow action that transforms input into output

@DataBindable
struct TransformData: Action {
    @Input var inputValue: String
    @Output var outputValue: String

    func run() {
        outputValue = inputValue + "_from_subflow"
    }
}

// MARK: - Subflow with declared @Input/@Output

@DataBindable
struct DataProducingSubflow: Workflow {
    enum State: String, WorkflowState {
        case processed
    }

    @Input var inputValue: String
    @Output var outputValue: String

    var transitions: Transitions {
        chainedAfterStart {
            TransformData.to(.processed)
            GoNextStep.toFinish()
        }
    }
}

// MARK: - Parent workflow that calls the subflow

@DataBindable
struct SubflowDataFlowWorkflow: Workflow {
    enum State: String, WorkflowState {
        case beforeSubflow
        case afterSubflow
    }

    @Input var inputValue: String

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.beforeSubflow)
        }

        on(.beforeSubflow) {
            DataProducingSubflow.to(.afterSubflow)
        }

        on(.afterSubflow) {
            Finalize.toFinish()
        }
    }
}
