//
//  AutomaticSubflowsWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 24.02.2026.
//

import WorkflowEngine

struct GoNextStep: Pass { }

struct SubflowX: Workflow {
    enum State: String, WorkflowState {
        case x1
        case x2
    }

    var transitions: Transitions {
        afterStart {
            GoNextStep.to(.x1)
            GoNextStep.to(.x2)
            GoNextStep.toFinish()
        }
    }
}

struct SubflowY: Workflow {
    enum State: String, WorkflowState {
        case y1
        case y2
        case y3
    }

    var transitions: Transitions {
        afterStart {
            GoNextStep.to(.y1)
            GoNextStep.to(.y2)
            GoNextStep.to(.y3)
            GoNextStep.toFinish()
        }
    }
}

struct AutomaticSubflowsWorkflow: Workflow {
    enum State: String, WorkflowState {
        case s1
        case s2
        case s3
    }

    var transitions: Transitions {
        afterStart {
            GoNextStep.to(.s1)
            SubflowX.to(.s2)
            SubflowY.to(.s3)
            GoNextStep.toFinish()
        }
    }
}
