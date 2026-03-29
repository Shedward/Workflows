//
//  AutomaticSubflowsWorkflow.swift
//  TestingWorkflows
//
//  Created by Vlad Maltsev on 24.02.2026.
//

import WorkflowEngine

struct GoNextStep: Pass { }

@DataBindable
struct SubflowX: Workflow {
    enum State: String, WorkflowState {
        case stepOne = "x1"
        case stepTwo = "x2"
    }

    var transitions: Transitions {
        chainedAfterStart {
            GoNextStep.to(.stepOne)
            GoNextStep.to(.stepTwo)
            GoNextStep.toFinish()
        }
    }
}

@DataBindable
struct SubflowY: Workflow {
    enum State: String, WorkflowState {
        case stepOne = "y1"
        case stepTwo = "y2"
        case stepThree = "y3"
    }

    var transitions: Transitions {
        chainedAfterStart {
            GoNextStep.to(.stepOne)
            GoNextStep.to(.stepTwo)
            GoNextStep.to(.stepThree)
            GoNextStep.toFinish()
        }
    }
}

@DataBindable
struct AutomaticSubflowsWorkflow: Workflow {
    enum State: String, WorkflowState {
        case stepOne = "s1"
        case stepTwo = "s2"
        case stepThree = "s3"
    }

    var transitions: Transitions {
        chainedAfterStart {
            GoNextStep.to(.stepOne)
            SubflowX.to(.stepTwo)
            SubflowY.to(.stepThree)
            GoNextStep.toFinish()
        }
    }
}
