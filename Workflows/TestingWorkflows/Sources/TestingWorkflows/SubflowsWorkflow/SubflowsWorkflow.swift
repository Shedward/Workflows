//
//  SubflowsWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

struct GoToSubflow: Pass { }
struct FinishAfterSubflow: Pass { }

@DataBindable
struct SubflowsWorkflow: Workflow {
    enum State: String, WorkflowState {
        case beforeSubflow
        case subflowFinished
        case afterSubflow
    }

    var transitions: Transitions {
        onStart {
            GoToSubflow.to(.beforeSubflow)
        }

        on(.beforeSubflow) {
            SimpleWorkflow.to(.subflowFinished)
        }

        on(.subflowFinished) {
            FinishAfterSubflow.toFinish()
        }
    }
}
