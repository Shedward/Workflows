//
//  SimpleWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import WorkflowEngine

struct Finalize: Pass { }

struct SimpleWorkflow: Workflow {
    enum State: String, WorkflowState {
        case stateA = "a"
        case stateB = "b"
    }

    var transitions: Transitions {
        onStart {
            StartA.to(.stateA)
        }

        on(.stateA) {
            StartB.to(.stateB)
        }

        on(.stateB) {
            Finalize.toFinish()
        }
    }
}
