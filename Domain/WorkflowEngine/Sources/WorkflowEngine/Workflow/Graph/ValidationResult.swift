//
//  ValidationResult.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowValidationResult: Sendable {
    public let workflowId: WorkflowID
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]

    public var isValid: Bool {
        errors.isEmpty
    }
}

public enum ValidationError: Sendable, CustomStringConvertible {
    case missingDependency(key: String, valueType: String, processId: TransitionProcessID)
    case unreachableFinish
    case deadEndState(StateID)
    case conditionallyAvailableInput(key: String, processId: TransitionProcessID, atState: StateID)
    case undeclaredWorkflowInput(key: String, processId: TransitionProcessID)
    case undeclaredWorkflowOutput(key: String)
    case typeMismatch(key: String, types: [String], atState: StateID)
    case unsatisfiedSubflowInput(key: String, subflowId: WorkflowID, atState: StateID)
    case automaticCycleWithoutExit([StateID])
    case circularSubflow([WorkflowID])
    case missingProviderDependency(key: String, valueType: String, providerType: String)

    public var description: String {
        switch self {
        case let .missingDependency(key, valueType, processId):
            "Dependency '\(key)' (\(valueType)) required by '\(processId)' is not registered"
        case .unreachableFinish:
            "No path from start to finish exists"
        case let .deadEndState(stateId):
            "State '\(stateId)' has no outgoing transitions and is not a finish state"
        case let .conditionallyAvailableInput(key, processId, atState):
            "Input '\(key)' required by '\(processId)' at state '\(atState)' is only available on some branches"
        case let .undeclaredWorkflowInput(key, processId):
            "Input '\(key)' required by '\(processId)' is not produced by any transition and not declared as workflow input"
        case let .undeclaredWorkflowOutput(key):
            "Declared workflow output '\(key)' is not produced on all paths to finish"
        case let .typeMismatch(key, types, atState):
            "Data key '\(key)' has conflicting types \(types.joined(separator: ", ")) at state '\(atState)'"
        case let .unsatisfiedSubflowInput(key, subflowId, atState):
            "Subflow '\(subflowId)' requires input '\(key)' which is not available at state '\(atState)'"
        case let .automaticCycleWithoutExit(states):
            "Cycle involving states \(states.joined(separator: " → ")) has only automatic transitions and no manual exit"
        case let .circularSubflow(workflows):
            "Circular subflow dependency detected: \(workflows.joined(separator: " → "))"
        case let .missingProviderDependency(key, valueType, providerType):
            "Dependency '\(key)' (\(valueType)) required by provider '\(providerType)' is not registered"
        }
    }
}

public enum ValidationWarning: Sendable, CustomStringConvertible {
    case unreachableState(StateID)
    case cycleDetected([StateID])
    case ambiguousAutomaticTransitions(state: StateID, count: Int)
    case unusedWorkflowInput(key: String)

    public var description: String {
        switch self {
        case let .unreachableState(stateId):
            "State '\(stateId)' is declared but never used in any transition"
        case let .cycleDetected(states):
            "Cycle detected involving states: \(states.joined(separator: " → "))"
        case let .ambiguousAutomaticTransitions(state, count):
            "State '\(state)' has \(count) automatic transitions (expected at most 1)"
        case let .unusedWorkflowInput(key):
            "Declared workflow input '\(key)' is never consumed by any transition"
        }
    }
}
