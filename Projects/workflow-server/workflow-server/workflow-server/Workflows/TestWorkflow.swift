//
//  TestWorkflow.swift
//  WorkflowServer
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import Git
import System
import WorkflowEngine

@DataBindable
struct StartA: Action {
    @Output var valueA: String

    func run() async throws {
        valueA = "Returned"
    }
}

@DataBindable
struct StartB: Action {
    @Input var valueA: String
    @Output var valueB: String

    func run() async throws {
        let repo = Git.Repository(path: "/Users/shed/Projects/Workflow")
        try await repo.assertExists()
        valueB = valueA + "_suffix"
    }
}


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

        on(.b) {
            Finalize.to(.end)
        }
    }
}
