//
//  Workflows+Errors.swift
//  Workflow
//
//  Created by Vlad Maltsev on 28.12.2025.
//

public enum WorkflowsError {
    public struct WorkflowNotFound: Swift.Error {
        public let workflowId: WorkflowID
    }

    public struct WorkflowInstanceNotFound: Swift.Error {
        public let instanceId: WorkflowInstanceID
    }

    public struct WorkflowInstanceMismatch: Swift.Error {
        public let instance: WorkflowInstanceID
        public let expectedWorkflow: WorkflowID
        public let foundWorkflow: WorkflowID
    }

    public struct TransitionNotFound: Swift.Error {
        public let transitionId: TransitionID
        public let availableTransitions: [TransitionID]
    }

    public struct TransitionProcessNotFoundForInstance: Swift.Error {
        public let instance: WorkflowInstanceID
        public let workflow: WorkflowID
        public let transitionId: TransitionProcessID
        public let availableTransitions: [TransitionID]
    }
}
