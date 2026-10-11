//
//  WorkflowGraph+API.swift
//  WorkflowServer
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import API
import WorkflowEngine

extension API.WorkflowGraph {
    init(model: WorkflowEngine.WorkflowGraph) {
        self.init(
            workflowId: model.workflowId,
            version: model.version,
            states: model.states.map { API.WorkflowGraph.State(model: $0) },
            transitions: model.transitions.map { API.WorkflowGraph.Transition(model: $0) },
            requiredInputs: model.requiredInputs.sortedByKey().map { API.DataField(model: $0) },
            producedOutputs: model.producedOutputs.sortedByKey().map { API.DataField(model: $0) }
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
            inputs: model.inputs.sortedByKey().map { API.DataField(model: $0) },
            outputs: model.outputs.sortedByKey().map { API.DataField(model: $0) },
            dependencies: model.dependencies.sortedByKey().map { API.DataField(model: $0) },
            asks: model.asks.sortedByKey().map { API.DataField(model: $0) }
        )
    }
}
