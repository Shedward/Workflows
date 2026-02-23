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
        case a
        case b
    }

    var transitions: Transitions {
        onStart {
            StartA.to(.a)
        }

        on(.a) {
            StartB.to(.b)
        }

        on(.b) {
            Finalize.toFinish()
        }
    }
}
