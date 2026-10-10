//
//  WorkflowsError+DescriptiveError.swift
//  WorkflowEngine
//

import Core
import Foundation

extension WorkflowsError.WorkflowNotFound: DescriptiveError {
    public var userDescription: String {
        "Workflow '\(workflowId)' is not registered"
    }
}

extension WorkflowsError.DuplicateWorkflowID: DescriptiveError {
    public var userDescription: String {
        "Workflow id '\(workflowId)' is claimed by two types: \(types.joined(separator: " and "))"
    }
}

extension WorkflowsError.WorkflowInstanceNotFound: DescriptiveError {
    public var userDescription: String {
        "Workflow instance '\(instanceId)' not found"
    }
}

extension WorkflowsError.TransitionProcessNotFoundForInstance: DescriptiveError {
    public var userDescription: String {
        let available = availableTransitions.map(\.processId).joined(separator: ", ")
        return "Transition '\(transitionId)' is not available for instance '\(instance)' of '\(workflow)'; available: \(available)"
    }
}

extension WorkflowsError.WorkflowVersionMismatch: DescriptiveError {
    public var userDescription: String {
        "Instance '\(instanceId)' was created by '\(workflowId)' version \(instanceVersion), but version \(workflowVersion) is registered"
    }
}

extension WorkflowsError.MissingRequiredInputs: DescriptiveError {
    public var userDescription: String {
        "Workflow '\(workflowId)' requires initial data for: \(missingKeys.sorted().joined(separator: ", "))"
    }
}

extension WorkflowsError.CircularSubflows: DescriptiveError {
    public var userDescription: String {
        "Subflows form a cycle: " + cycles.map { $0.joined(separator: " → ") }.joined(separator: "; ")
    }
}

extension WorkflowsError.InvalidRouteTarget: DescriptiveError {
    public var userDescription: String {
        "Transition '\(transitionId.processId)' routed to '\(requestedTarget)', which is not one of its targets \(allowedTargets)"
    }
}

extension WorkflowsError.InstanceNotAsking: DescriptiveError {
    public var userDescription: String {
        "Workflow instance '\(instanceId)' is not waiting for an answer"
    }
}

extension WorkflowsError.InputBindingFailed: DescriptiveError {
    public var userDescription: String {
        switch reason {
            case .missing:
                "Input '\(key)' is missing"
            case .decodingFailed(let error):
                "Input '\(key)' could not be decoded: \(error)"
        }
    }
}

extension WorkflowsError.DependencyBindingFailed: DescriptiveError {
    public var userDescription: String {
        switch reason {
            case .missing:
                "Dependency '\(key)' is not registered"
            case let .typeMismatch(expected, actual):
                "Dependency '\(key)' is \(actual), expected \(expected)"
        }
    }
}

extension WorkflowsError.AutomaticLoopDetected: DescriptiveError {
    public var userDescription: String {
        "Automatic transitions keep repeating at state '\(state)' via '\(transitionId.processId)' without changing any data"
    }
}

extension WorkflowsError.AutomaticStepLimitReached: DescriptiveError {
    public var userDescription: String {
        "Automatic chain was stopped after \(limit) steps, with '\(transitionId.processId)' at state '\(state)' still pending"
    }
}

extension WorkflowsError.ValidationFailed: DescriptiveError {
    public var userDescription: String {
        let nonEmpty = results.filter { !$0.errors.isEmpty || !$0.warnings.isEmpty }
        var out = "Workflow validation failed - \(nonEmpty.count) workflows have errors\n"
        for result in nonEmpty {
            out += "\n  \(result.workflowId)\n"
            if !result.errors.isEmpty {
                out += "    errors (\(result.errors.count)):\n"
                for error in result.errors {
                    out += formatBullet(String(describing: error))
                }
            }
            if !result.warnings.isEmpty {
                out += "    warnings (\(result.warnings.count)):\n"
                for warning in result.warnings {
                    out += formatBullet(String(describing: warning))
                }
            }
        }
        return out
    }
}

private func formatBullet(_ message: String) -> String {
    let bullet = "      - "
    let cont = "        "
    let lines = wrap(message, width: 80 - cont.count)
    return lines.enumerated()
        .map { index, line in (index == 0 ? bullet : cont) + line }
        .joined(separator: "\n") + "\n"
}

private func wrap(_ text: String, width: Int) -> [String] {
    var result: [String] = []
    var current = ""
    for word in text.split(separator: " ") {
        if current.isEmpty {
            current = String(word)
        } else if current.count + 1 + word.count <= width {
            current += " \(word)"
        } else {
            result.append(current)
            current = String(word)
        }
    }
    if !current.isEmpty { result.append(current) }
    return result.isEmpty ? [text] : result
}
