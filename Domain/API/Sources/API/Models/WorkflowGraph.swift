//
//  WorkflowGraph.swift
//  API
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import Rest

public struct WorkflowGraph: JSONBody {

    public struct State: JSONBody {
        public let id: String
        public let isStart: Bool
        public let isFinish: Bool

        public init(id: String, isStart: Bool, isFinish: Bool) {
            self.id = id
            self.isStart = isStart
            self.isFinish = isFinish
        }
    }

    public struct TransitionMetadata: JSONBody {
        public let processId: String
        public let inputs: [DataField]
        public let outputs: [DataField]
        public let dependencies: [DataField]
        public let asks: [DataField]

        public init(processId: String, inputs: [DataField], outputs: [DataField], dependencies: [DataField], asks: [DataField]) {
            self.processId = processId
            self.inputs = inputs
            self.outputs = outputs
            self.dependencies = dependencies
            self.asks = asks
        }
    }

    public struct Transition: JSONBody {
        public let id: TransitionID
        public let from: String
        public let targets: [String]
        public let processId: String
        public let trigger: String
        public let metadata: TransitionMetadata
        public let subflowId: String?

        public init(
            id: TransitionID,
            from: String,
            targets: [String],
            processId: String,
            trigger: String,
            metadata: TransitionMetadata,
            subflowId: String?
        ) {
            self.id = id
            self.from = from
            self.targets = targets
            self.processId = processId
            self.trigger = trigger
            self.metadata = metadata
            self.subflowId = subflowId
        }
    }

    public let workflowId: String
    public let version: Int
    public let states: [State]
    public let transitions: [Transition]
    public let requiredInputs: [DataField]
    public let producedOutputs: [DataField]

    public init(
        workflowId: String,
        version: Int,
        states: [State],
        transitions: [Transition],
        requiredInputs: [DataField],
        producedOutputs: [DataField]
    ) {
        self.workflowId = workflowId
        self.version = version
        self.states = states
        self.transitions = transitions
        self.requiredInputs = requiredInputs
        self.producedOutputs = producedOutputs
    }
}
