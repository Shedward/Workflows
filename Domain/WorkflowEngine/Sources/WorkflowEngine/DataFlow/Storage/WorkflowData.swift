//
//  WorkflowData.swift
//  Workflow
//
//  Created by Vlad Maltsev on 04.01.2026.
//

import Core
import Foundation

public struct WorkflowData: Sendable, Codable, Hashable {
    internal var data: [String: String]

    public init(data: [String: String] = [:]) {
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        data = try container.decode([String: String].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(data)
    }

    public func get<Value: WorkflowValue>(_ key: String) throws -> Value? {
        guard let string = data[key] else {
            return nil
        }

        guard let data = string.data(using: .utf8) else {
            throw Failure("Failed to convert string to data")
        }

        return try JSONDecoder().decode(Value.self, from: data)
    }

    public mutating func set<Value: WorkflowValue>(_ key: String, _ value: Value) throws {
        let valueData = try JSONEncoder().encode(value)
        guard let string = String(data: valueData, encoding: .utf8) else {
            throw Failure("Failed to convert data to string")
        }
        data[key] = string
    }
}
