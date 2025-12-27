//
//  RestRequest+CustomStringConvertible.swift
//  RestClient
//
//  Created by Vlad Maltsev on 22.12.2025.
//

import Foundation

extension Request: CustomStringConvertible {
    public var shortDescription: String {
        """
        RestRequest<\(RequestBody.self), \(ResponseBody.self)>(
            \(methodDescription)
        )
        """
    }

    public var description: String {
        var description = """
            RestRequest<\(RequestBody.self), \(ResponseBody.self)>(
            \(methodDescription.indented())\n\n
            """

        if !query.isEmpty {
            description += "\(query);\n"
                .indented()
        }
        if !headers.isEmpty {
            description += "\(headers);\n"
                .indented()
        }
        if !(body is EmptyBody) {
            description += "Body: \(body);\n"
                .indented()
        }

        description += ")"

        return description
    }

    private var methodDescription: String {
        "\(method.rawValue) \(path ?? "/")"
    }
}

extension Query: CustomStringConvertible {
    public var description: String {
        if values.isEmpty {  return "Query()" }

        let valuesList = values
            .filter { $1.queryValue != nil }
            .map { "\($0) = \($1.queryValue ?? "nil")"}
            .joined(separator: "\n")

        return """
        Query(
        \(valuesList.indented())
        )
        """
    }
}

extension Headers: CustomStringConvertible {
    public var description: String {
        if values.isEmpty {  return "Headers()" }

        let valuesList = values
            .map { "  \($0): \(redactHeaderIfNeeded($0, value: $1))"}
            .joined(separator: "\n")

        return """
        Headers(
        \(valuesList.indented())
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

