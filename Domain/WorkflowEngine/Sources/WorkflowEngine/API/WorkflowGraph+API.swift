//
//  WorkflowGraph+API.swift
//  WorkflowEngine
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import API

extension API.WorkflowGraph {
    public init(model: WorkflowEngine.WorkflowGraph) {
        self.init(
            workflowId: model.workflowId,
            version: model.version,
            states: model.states.map { API.WorkflowGraph.State(model: $0) },
            transitions: model.transitions.map { API.WorkflowGraph.Transition(model: $0) },
            requiredInputs: model.requiredInputs.map { API.DataField(model: $0) },
            producedOutputs: model.producedOutputs.map { API.DataField(model: $0) }
        )
    }
}

extension API.WorkflowGraph.State {
    init(model: WorkflowEngine.WorkflowGraph.State) {
        self.init(id: model.id, isStart: model.isStart, isFinish: model.isFinish)
    }
}

extension API.WorkflowGraph.Transition {
    init(model: WorkflowEngine.WorkflowGraph.Transition) {
        self.init(
            id: API.TransitionID(model: model.id),
            from: model.from,
            targets: model.targets,
            processId: model.processId,
            trigger: model.trigger.rawValue,
            metadata: API.WorkflowGraph.TransitionMetadata(model: model.metadata),
            subflowId: model.subflowId
        )
    }
}

extension API.WorkflowGraph.TransitionMetadata {
    init(model: WorkflowEngine.TransitionMetadata) {
        self.init(
            processId: model.processId,
            inputs: model.inputs.map { API.DataField(model: $0) },
            outputs: model.outputs.map { API.DataField(model: $0) },
            dependencies: model.dependencies.map { API.DataField(model: $0) }
        )
    }
}
