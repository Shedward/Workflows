//
//  WorkflowData.swift
//  Workflow
//
//  Created by Vlad Maltsev on 04.01.2026.
//

import Core
import Foundation

public struct WorkflowData: Sendable {
    internal var data: [String: String]

    public init(data: [String: String] = [:]) {
        self.data = data
    }

    public func get<Value: WorkflowValue>(_ key: String) throws -> Value? {
        guard let string = data[key] else {
            return nil
        }

        guard let data = string.data(using: .utf8) else {
            throw Failure("Failed to convert string to data")
        }

        let value = try JSONDecoder().decode(Value.self, from: data)
        return value
    }


    public mutating func set<Value: WorkflowValue>(_ key: String, _ value: Value) throws {
        let valueData = try JSONEncoder().encode(value)
        guard let string = String(data: valueData, encoding: .utf8) else {
            throw Failure("Failed to convert data to string")
        }
        data[key] = string
    }
}
