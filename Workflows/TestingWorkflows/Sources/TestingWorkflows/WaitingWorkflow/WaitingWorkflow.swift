//
//  WaitingWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import WorkflowEngine

struct WaitingWorkflow: Workflow {
    enum State: String, WorkflowState {
        case templateCreated
        case messageReady
    }

    var transitions: Transitions {
        onStart {
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
