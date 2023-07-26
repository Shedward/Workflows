//
//  DebugRepresentations.swift
//  Created by Vladislav Maltsev on 27.07.2023.
//

import Foundation


extension RestRequest: CustomStringConvertible {

    public var shortDescription: String {
        """
        RestRequest<\(RequestBody.self), \(ResponseBody.self)>(
          \(methodDescription())
        )
        """
    }

    public var description: String {
        var description = """
        RestRequest<\(RequestBody.self), \(ResponseBody.self)>(
        \(methodDescription())\n
        """

        if !query.isEmpty {
            description += "\(query);\n"
        }
        if !headers.isEmpty {
            description += "\(headers);\n"
        }
        if !(body is EmptyBody) {
            description += "Body: \(body);\n"
        }

        description += ")"

        return description
    }

    private func methodDescription() -> String {
        "\(method.rawValue) \(path ?? "/")"
    }
}

extension RestQuery: CustomStringConvertible {
    public var description: String {
        if values.isEmpty {  return "RestQuery()" }

        return """
        RestQuery(
        \(values
            .map { "  \($0) = \($1)"}
            .joined(separator: "\n"))
        )
        """
    }
}

extension RestHeaders: CustomStringConvertible {
    public var description: String {
        if values.isEmpty {  return "RestHeaders()" }

        return """
        RestHeaders(
        \(values
            .map { "  \($0): \(redactHeaderIfNeeded($0, value: $1))"}
            .joined(separator: "\n"))
        )
        """
    }

    private func redactHeaderIfNeeded(_ key: String, value: String) -> String {
        if shouldRedactHeader(key) {
            return String(repeating: "█", count: value.count)
        } else {
            return value
        }
    }

    private func shouldRedactHeader(_ key: String) -> Bool {
        switch key {
        case "Authorization":
            return true
        default:
            return false
        }
    }
}
