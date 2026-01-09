//
//  ReadOutputs.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

import Core

struct ReadOutputs: DataBinding {
    var data: WorkflowData

    mutating func output<Value>(for key: String, at output: inout Output<Value>) throws where Value : Sendable {
        guard let value = output.storage?.value else {
            throw Failure("Value is not provided in output \(key)")
        }

        guard let value = value as? Value else {
            throw Failure("Expected \(Value.self) found \(type(of: value))")
        }
        
        try data.set(key, value)
    }
}
