//
//  TestWorkflow.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import WorkflowEngine

struct StartA: Pass { }
struct StartB: Pass { }
struct Finalize: Pass { }

struct TestWorkflow: Workflow {

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

        after(.b) {
            Finalize.to(.end)
        }

        always {
            Finalize.to(.end)
        }
    }
}
