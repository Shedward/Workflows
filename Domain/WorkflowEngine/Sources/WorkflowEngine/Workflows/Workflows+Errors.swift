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

    public struct WorkflowVersionMismatch: Swift.Error {
        public let instanceId: WorkflowInstanceID
        public let workflowId: WorkflowID
        public let instanceVersion: WorkflowVersion
        public let workflowVersion: WorkflowVersion
    }

    public struct ValidationFailed: Swift.Error {
        public let results: [WorkflowValidationResult]
    }

    public struct MissingRequiredInputs: Swift.Error {
        public let workflowId: WorkflowID
        public let missingKeys: Set<String>
    }

    public struct CircularSubflows: Swift.Error {
        public let cycles: [[WorkflowID]]
    }

    public struct InvalidRouteTarget: Swift.Error {
        public let transitionId: TransitionID
        public let requestedTarget: StateID
        public let allowedTargets: [StateID]
    }

    public struct InstanceNotAsking: Swift.Error {
        public let instanceId: WorkflowInstanceID
    }
}
