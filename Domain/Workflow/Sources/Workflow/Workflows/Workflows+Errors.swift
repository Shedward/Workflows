//
//  Workflows+Errors.swift
//  Workflow
//
//  Created by Vlad Maltsev on 28.12.2025.
//

public enum WorkflowsError {
    public struct WorkflowNotFound: Swift.Error {
        let workflowId: WorkflowID
    }

    public struct WorkflowInstanceNotFound: Swift.Error {
        let instanceId: WorkflowInstanceID
    }

    public struct WorkflowInstanceMismatch: Swift.Error {
        let instance: WorkflowInstanceID
        let found: WorkflowID
    }

    public struct TransitionNotFound: Swift.Error {
        let transitionId: TransitionID
    }
}
