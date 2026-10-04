//
//  WorkflowGraphBuilder.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowGraphBuilder: Sendable {
    /// A workflow's graph together with the facts its validation is based on.
    struct Built: Sendable {
        let graph: WorkflowGraph
        let declaredOutputs: Set<DataField>
        let topology: GraphTopology
        let availability: DataAvailability
    }

    private var cache: [WorkflowID: Built] = [:]

    public init() {}

    public mutating func build(from workflow: AnyWorkflow) -> WorkflowGraph {
        built(from: workflow).graph
    }

    mutating func built(from workflow: AnyWorkflow) -> Built {
        if let cached = cache[workflow.id] {
            return cached
        }

        let transitions = transitions(of: workflow)
        let declared = (workflow as? any DataBindable & Defaultable)?.declaredMetadata(processId: workflow.id)
            ?? .empty(processId: workflow.id)
        let topology = GraphTopology(transitions: transitions, start: workflow.startId)
        let availability = DataAvailability(in: topology, declaredInputs: declared.inputs)
        let typesAtFinish = availability.types(at: workflow.finishId)

        let built = Built(
            graph: WorkflowGraph(
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
            ),
            declaredOutputs: declared.outputs,
            topology: topology,
            availability: availability
        )
        cache[workflow.id] = built
        return built
    }

    func cachedGraph(for workflowId: WorkflowID) -> WorkflowGraph? {
        cache[workflowId]?.graph
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
