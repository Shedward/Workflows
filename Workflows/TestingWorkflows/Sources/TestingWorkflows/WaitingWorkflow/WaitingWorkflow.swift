//
//  WaitingWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

struct WaitingWorkflow: Workflow {
    enum State: String, WorkflowState {
        static let initial = State.begin
        static let final = State.end

        case begin
        case templateCreated
        case messageReady
        case end
    }

    var transitions: Transitions {
        on(.initial) {
            CreateMessageTemplateFile.to(.templateCreated)
        }

        after(.templateCreated) {
            WaitForFileContent.to(.messageReady)
        }

        on(.messageReady) {
            SendMessage.toFinish()
        }
    }
}
