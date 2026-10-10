//
//  WorkflowGraphBuilder.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowGraphBuilder: Sendable {
    private var cache: [WorkflowID: WorkflowGraph] = [:]

    public init() {}

    public mutating func build(from workflow: AnyWorkflow) -> WorkflowGraph {
        if let cached = cache[workflow.id] {
            return cached
        }

        let transitions = transitions(of: workflow)
        let declared = workflow.declaredMetadata
        let topology = GraphTopology(transitions: transitions, start: workflow.startId)
        let typesAtFinish = DataAvailability(in: topology, declaredInputs: declared.inputs).types(at: workflow.finishId)

        let graph = WorkflowGraph(
            workflowId: workflow.id,
            version: workflow.version,
            states: states(of: workflow),
            transitions: transitions,
            requiredInputs: declared.inputs,
            producedOutputs: Set(
                declared.outputs.compactMap { output in
                    typesAtFinish[output.key].map { DataField(key: output.key, valueType: $0) }
                }
            )
        )
        cache[workflow.id] = graph
        return graph
    }

    private func states(of workflow: AnyWorkflow) -> [WorkflowGraph.State] {
        [WorkflowGraph.State(id: workflow.startId, isStart: true, isFinish: false)]
            + workflow.states.map { WorkflowGraph.State(id: $0, isStart: false, isFinish: false) }
            + [WorkflowGraph.State(id: workflow.finishId, isStart: false, isFinish: true)]
    }

    private func transitions(of workflow: AnyWorkflow) -> [WorkflowGraph.Transition] {
        workflow.anyTransitions.map { transition in
            WorkflowGraph.Transition(
                id: transition.id,
                from: transition.from,
                targets: transition.targets,
                processId: transition.process.id,
                trigger: transition.trigger,
                metadata: transition.process.collectMetadata(),
                subflowId: (transition.process as? AnyWorkflow)?.id
            )
        }
    }
}
