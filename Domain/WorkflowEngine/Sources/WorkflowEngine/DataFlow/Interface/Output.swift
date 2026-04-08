//
//  Output.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

@propertyWrapper
public struct Output<Value: WorkflowValue>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        @available(*, unavailable, message: "Output values are write-only")
        get {
            preconditionFailure("Output values are write-only")
        }
        nonmutating set {
            // CreateOutputStorage attaches a ValueStorage to every declared
            // Output before the transition runs. A nil storage here means
            // the binding step was skipped — i.e. an engine bug.
            guard let storage else {
                preconditionFailure("Output<\(Value.self)> written before CreateOutputStorage ran (engine bug)")
            }
            storage.value = newValue
        }
    }

    public init(key: StaticString? = nil) {
    }
}
