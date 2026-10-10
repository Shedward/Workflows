//
//  UnicodeIdWorkflow.swift
//  TestingWorkflows
//

import WorkflowEngine

/// Its id needs percent-encoding in a URL path, like every production workflow id.
@DataBindable
struct UnicodeIdWorkflow: Workflow {
    enum State: String, WorkflowState {
        case middle = "середина"
    }

    var id: WorkflowID {
        "Юникод_процесс"
    }

    var transitions: Transitions {
        onStart {
            StartA.to(.middle)
        }

        on(.middle) {
            Finalize.toFinish()
        }
    }
}
