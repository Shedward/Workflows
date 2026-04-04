//
//  AskWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 04.04.2026.
//

import WorkflowEngine

struct GoToAsk: Pass { }
struct FinishAfterAsk: Pass { }

// Simple ask: just collects user input
@DataBindable
struct AskNameWorkflow: Workflow {
    enum State: String, WorkflowState {
        case waitingName
        case done
    }

    var transitions: Transitions {
        onStart {
            GoToAsk.to(.waitingName)
        }

        on(.waitingName) {
            AskName.to(.done)
        }

        on(.done) {
            FinishAfterAsk.toFinish()
        }
    }
}

@DataBindable
struct AskName: Asking {
    @Ask var name: String

    var prompt: Prompt? {
        "What is your name?"
    }

    func process() async throws {
    }
}

// Ask with @Input + @Ask + @Output
@DataBindable
struct AskWithDataWorkflow: Workflow {
    enum State: String, WorkflowState {
        case setup
        case waitingResponse
        case done
    }

    var transitions: Transitions {
        onStart {
            SetGreeting.to(.setup)
        }

        on(.setup) {
            AskWithContext.to(.waitingResponse)
        }

        on(.waitingResponse) {
            ProcessResponse.to(.done)
        }

        on(.done) {
            FinishAfterAsk.toFinish()
        }
    }
}

@DataBindable
struct SetGreeting: Action {
    @Output var greeting: String

    func run() async throws {
        greeting = "Hello"
    }
}

@DataBindable
struct AskWithContext: Asking {
    @Input var greeting: String
    @Ask var response: String
    @Output var fullMessage: String

    var prompt: Prompt? {
        "Please respond to the greeting"
    }

    func process() async throws {
        fullMessage = "\(greeting), \(response)!"
    }
}

@DataBindable
struct ProcessResponse: Action {
    @Input var fullMessage: String
    @Input var response: String

    func run() async throws {
    }
}
