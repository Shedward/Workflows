//
//  WorkflowsError+DescriptiveError.swift
//  WorkflowEngine
//

import Core
import Foundation

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
