//
//  DependencyErrorWorkflows.swift
//  TestingWorkflows
//
//  Created by Claude on 29.03.2026.
//

import WorkflowEngine

// MARK: - Triggers: missingDependency

protocol UnregisteredService: Sendable { }

@DataBindable
struct NeedsMissingDependency: Action {
    @Dependency var service: UnregisteredService
    func run() { }
}

@DataBindable
struct MissingDependencyWorkflow: Workflow {
    enum State: String, WorkflowState {
        case done
    }

    var transitions: Transitions {
        onStart {
            NeedsMissingDependency.to(.done)
        }

        on(.done) {
            Finalize.toFinish()
        }
    }
}
