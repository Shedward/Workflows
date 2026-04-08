//
//  BindInputs.swift
//  Workflow
//
//  Created by Vlad Maltsev on 05.01.2026.
//

import Core

struct BindInputs: DataBinding {
    let data: WorkflowData

    func input<Value>(for key: String, at input: inout Input<Value>) throws where Value: Sendable {
        let decoded: Value?
        do {
            decoded = try data.get(key) as Value?
        } catch {
            throw WorkflowsError.InputBindingFailed(key: key, reason: .decodingFailed(error))
        }
        guard let inputValue = decoded else {
            throw WorkflowsError.InputBindingFailed(key: key, reason: .missing)
        }
        input.storage = ValueStorage(inputValue)
    }
}
