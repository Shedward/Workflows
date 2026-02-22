//
//  BindInputs.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

import Core

struct BindInputs: DataBinding {
    let data: WorkflowData

    func input<Value>(for key: String, at input: inout Input<Value>) throws where Value : Sendable {
        guard let inputValue = try data.get(key) as Value? else {
            throw Failure("Input \(key) is not set")
        }
        input.storage = ValueStorage(inputValue)
    }
}
