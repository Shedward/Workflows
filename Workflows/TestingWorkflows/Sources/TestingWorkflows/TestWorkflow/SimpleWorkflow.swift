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
        static let initial = State.begin
        static let final = State.end

        case begin
        case a
        case b
        case end
    }

    var transitions: Transitions {
        on(.begin) {
            StartA.to(.a)
        }

        on(.a) {
            StartB.to(.b)
        }

        on(.b) {
            Finalize.to(.end)
        }
    }
}
