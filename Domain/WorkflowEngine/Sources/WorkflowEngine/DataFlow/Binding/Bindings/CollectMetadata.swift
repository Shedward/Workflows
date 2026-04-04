//
//  CollectMetadata.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct TransitionMetadata: Sendable, Equatable {

    public static func empty(processId: TransitionProcessID) -> TransitionMetadata {
        TransitionMetadata(processId: processId, inputs: [], outputs: [], dependencies: [], asks: [])
    }

    public let processId: TransitionProcessID
    public let inputs: Set<DataField>
    public let outputs: Set<DataField>
    public let dependencies: Set<DataField>
    public let asks: Set<DataField>

    public var inputKeys: Set<String> {
        Set(inputs.map(\.key))
    }

    public var outputKeys: Set<String> {
        Set(outputs.map(\.key))
    }

    public var dependencyKeys: Set<String> {
        Set(dependencies.map(\.key))
    }

    public var askKeys: Set<String> {
        Set(asks.map(\.key))
    }
}

struct CollectMetadata: DataBinding {

    private(set) var inputs: Set<DataField> = []
    private(set) var outputs: Set<DataField> = []
    private(set) var dependencies: Set<DataField> = []
    private(set) var asks: Set<DataField> = []

    mutating func input<Value: Sendable>(for key: String, at input: inout Input<Value>) {
        inputs.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    mutating func output<Value: Sendable>(for key: String, at output: inout Output<Value>) {
        outputs.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    mutating func dependency<Value: Sendable>(for key: String, at dependency: inout Dependency<Value>) {
        dependencies.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    mutating func ask<Value: Sendable>(for key: String, at ask: inout Ask<Value>) {
        let field = DataField(key: key, valueType: String(describing: Value.self))
        asks.insert(field)
        outputs.insert(field)
    }

    func metadata(processId: TransitionProcessID) -> TransitionMetadata {
        TransitionMetadata(
            processId: processId,
            inputs: inputs,
            outputs: outputs,
            dependencies: dependencies,
            asks: asks
        )
    }
}

extension TransitionProcess {
    func collectMetadata() -> TransitionMetadata {
        guard var bindable = self as? any DataBindable & Defaultable else {
            return .empty(processId: id)
        }

        var collector = CollectMetadata()
        try? bindable.bind(&collector)
        return collector.metadata(processId: id)
    }
}
