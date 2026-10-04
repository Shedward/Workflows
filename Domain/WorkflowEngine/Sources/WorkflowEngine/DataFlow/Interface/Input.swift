//
//  Input.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Input<Value: WorkflowValue>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        storage.boundValue(of: "Input", boundBy: "BindInputs")
    }

    public init(key: StaticString? = nil) {
    }
}
