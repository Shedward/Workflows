//
//  BindAskInputs.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 04.04.2026.
//

import Core

struct BindAskInputs: DataBinding {
    let data: WorkflowData

    func ask<Value>(for key: String, at ask: inout Ask<Value>) throws where Value: Sendable {
        guard let askValue = try data.get(key) as Value? else {
            throw Failure("Ask input \(key) is not provided")
        }
        ask.storage = ValueStorage(askValue)
    }
}
