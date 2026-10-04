//
//  ReadOutputs.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

import Core

struct ReadOutputs: DataBinding {
    var data: WorkflowData

    mutating func output<Value>(for key: String, at output: inout Output<Value>) throws where Value: Sendable {
        try write(output.storage, as: Value.self, to: key, of: "output")
    }

    mutating func ask<Value>(for key: String, at ask: inout Ask<Value>) throws where Value: Sendable {
        try write(ask.storage, as: Value.self, to: key, of: "ask")
    }

    private mutating func write<Value: WorkflowValue>(
        _ storage: ValueStorage?,
        as valueType: Value.Type,
        to key: String,
        of wrapper: String
    ) throws {
        guard let value = storage?.value else {
            throw Failure("Value is not provided in \(wrapper) \(key)")
        }

        guard let value = value as? Value else {
            throw Failure("Expected \(Value.self) found \(type(of: value))")
        }

        try data.set(key, value)
    }
}
