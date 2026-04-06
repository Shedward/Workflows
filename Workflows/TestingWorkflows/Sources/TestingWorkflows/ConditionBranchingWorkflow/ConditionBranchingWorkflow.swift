//
//  ConditionBranchingWorkflow.swift
//  TestingWorkflows
//

import WorkflowEngine

// Condition that reads "choice" input and routes to left or right.
@DataBindable
struct ChooseDirection: Condition {
    typealias State = ConditionBranchingWorkflow.State

    static var possibleTargets: [State] { [.left, .right] }

    @Input var choice: String

    func check() -> State {
        choice == "left" ? .left : .right
    }
}

// Workflow: start with a condition that branches based on initial data.
@DataBindable
struct ConditionBranchingWorkflow: Workflow {
    enum State: String, WorkflowState {
        case left
        case right
    }

    @Input var choice: String

    var transitions: Transitions {
        onStart {
            ChooseDirection.branching()
        }

        on(.left) {
            Finalize.toFinish()
        }

        on(.right) {
            Finalize.toFinish()
        }
    }
}

// Condition that also writes an output label while routing.
@DataBindable
struct ChooseAndLabel: Condition {
    typealias State = ConditionOutputWorkflow.State

    static var possibleTargets: [State] { [.left, .right] }

    @Input var choice: String
    @Output var label: String

    func check() -> State {
        if choice == "left" {
            label = "went-left"
            return .left
        } else {
            label = "went-right"
            return .right
        }
    }
}

// Workflow: condition produces output data alongside routing.
@DataBindable
struct ConditionOutputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case left
        case right
    }

    @Input var choice: String

    var transitions: Transitions {
        onStart {
            ChooseAndLabel.branching()
        }

        on(.left) {
            Finalize.toFinish()
        }

        on(.right) {
            Finalize.toFinish()
        }
    }
}
