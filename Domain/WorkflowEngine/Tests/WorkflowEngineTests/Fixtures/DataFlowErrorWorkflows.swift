//
//  DataFlowErrorWorkflows.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Helper Actions

@DataBindable
struct ProduceString: Action {
    @Output var data: String
    func run() {
      data = "hello"
    }
}

@DataBindable
struct ProduceInt: Action {
    @Output var data: Int
    func run() {
      data = 42
    }
}

@DataBindable
struct ConsumeString: Action {
    @Input var data: String
    func run() {
    }
}

@DataBindable
struct ConsumeGhost: Action {
    @Input var ghost: String
    func run() {
    }
}

// MARK: - Triggers: undeclaredWorkflowInput

@DataBindable
struct UndeclaredInputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    var transitions: Transitions {
        onStart {
            ConsumeGhost.to(.done)
        }

        on(.done) {
            Finalize.toFinish()
        }
    }
}

// MARK: - Triggers: undeclaredWorkflowOutput

@DataBindable
struct UndeclaredOutputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    @Output var result: String

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.done)
        }

        on(.done) {
            Finalize.toFinish()
        }
    }
}

// MARK: - Triggers: conditionallyAvailableInput

@DataBindable
struct ConditionalInputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case fork
        case left
        case right
        case merge
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.fork)
        }

        on(.fork) {
            ProduceString.to(.left)
            GoNextStep.to(.right)
        }

        on(.left, .right) {
            GoNextStep.to(.merge)
        }

        on(.merge) {
            ConsumeString.toFinish()
        }
    }
}

// MARK: - Triggers: typeMismatch

@DataBindable
struct TypeMismatchWorkflow: Workflow {
    enum State: String, WorkflowState {
        case fork
        case left
        case right
        case merge
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.fork)
        }

        on(.fork) {
            ProduceString.to(.left)
            ProduceInt.to(.right)
        }

        on(.left, .right) {
            GoNextStep.to(.merge)
        }

        on(.merge) {
            Finalize.toFinish()
        }
    }
}

// MARK: - Triggers: unusedWorkflowInput (warning)

@DataBindable
struct UnusedInputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    @Input var unused: String

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.done)
        }

        on(.done) {
            Finalize.toFinish()
        }
    }
}
