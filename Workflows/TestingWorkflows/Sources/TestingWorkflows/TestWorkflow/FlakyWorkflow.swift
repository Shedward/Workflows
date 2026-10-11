//
//  FlakyWorkflow.swift
//  TestingWorkflows
//

import Core
import Synchronization
import WorkflowEngine

private let failedAttemptKeys = Mutex<Set<String>>([])

@DataBindable
struct FailOnceAction: Action {
    @Input var attemptKey: String

    func run() throws {
        let isFirstAttempt = failedAttemptKeys.withLock { $0.insert(attemptKey).inserted }
        if isFirstAttempt {
            throw Failure("Intentional first-attempt failure for '\(attemptKey)'")
        }
    }
}

@DataBindable
struct FlakyWorkflow: Workflow {
    enum State: String, WorkflowState {
        case recovered
    }

    @Input var attemptKey: String

    var transitions: Transitions {
        afterStart {
            FailOnceAction.to(.recovered)
        }

        on(.recovered) {
            GoNextStep.toFinish()
        }
    }
}
