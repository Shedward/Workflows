//
//  CollectMetadata.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct TransitionMetadata: Sendable, Codable, Equatable {

    public struct Field: Sendable, Codable, Hashable {
        public let key: String
        public let valueType: String
    }

    public static func empty(processId: TransitionProcessID) -> TransitionMetadata {
        TransitionMetadata(processId: processId, inputs: [], outputs: [], dependencies: [])
    }

    public let processId: TransitionProcessID
    public let inputs: Set<Field>
    public let outputs: Set<Field>
    public let dependencies: Set<Field>

    public var inputKeys: Set<String> {
        Set(inputs.map(\.key))
    }

    public var outputKeys: Set<String> {
        Set(outputs.map(\.key))
    }

    public var dependencyKeys: Set<String> {
        Set(dependencies.map(\.key))
    }
}

struct CollectMetadata: DataBinding {

    private(set) var inputs: Set<TransitionMetadata.Field> = []
    private(set) var outputs: Set<TransitionMetadata.Field> = []
    private(set) var dependencies: Set<TransitionMetadata.Field> = []

    mutating func input<Value: Sendable>(for key: String, at input: inout Input<Value>) {
        inputs.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    mutating func output<Value: Sendable>(for key: String, at output: inout Output<Value>) {
        outputs.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    mutating func dependency<Value: Sendable>(for key: String, at dependency: inout Dependency<Value>) {
        dependencies.insert(.init(key: key, valueType: String(describing: Value.self)))
    }

    func metadata(processId: TransitionProcessID) -> TransitionMetadata {
        TransitionMetadata(
            processId: processId,
            inputs: inputs,
            outputs: outputs,
            dependencies: dependencies
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
