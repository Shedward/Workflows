//
//  WorkflowGraph.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowGraph: Sendable, Equatable {
    public struct State: Sendable, Equatable {
        public let id: StateID
        public let isStart: Bool
        public let isFinish: Bool
    }

    public struct Transition: Sendable, Equatable {
        public let id: TransitionID
        public let from: StateID
        public let to: StateID
        public let processId: TransitionProcessID
        public let trigger: TransitionTrigger
        public let metadata: TransitionMetadata
        public let subflowId: WorkflowID?
    }

    public let workflowId: WorkflowID
    public let version: WorkflowVersion
    public let states: [State]
    public let transitions: [Transition]
    public let requiredInputs: Set<DataField>
    public let producedOutputs: Set<DataField>
}
