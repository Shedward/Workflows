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

        let states = buildStates(from: workflow)
        let transitions = buildTransitions(from: workflow)

        let declaredIO = collectWorkflowIO(workflow)

        let context = DataFlowAnalyzer.Context(
            transitions: transitions,
            states: states,
            declaredInputKeys: declaredIO.inputKeys,
            declaredOutputKeys: declaredIO.outputKeys,
            startId: workflow.startId,
            finishId: workflow.finishId
        )
        let analysis = DataFlowAnalyzer.analyze(context)

        let graph = WorkflowGraph(
            workflowId: workflow.id,
            version: workflow.version,
            states: states,
            transitions: transitions,
            requiredInputs: analysis.requiredInputs,
            producedOutputs: analysis.producedOutputs
        )

        cache[workflow.id] = graph
        return graph
    }

    private func buildStates(from workflow: AnyWorkflow) -> [WorkflowGraph.State] {
        var states: [WorkflowGraph.State] = []
        states.append(.init(id: workflow.startId, isStart: true, isFinish: false))
        for stateId in workflow.states {
            states.append(.init(id: stateId, isStart: false, isFinish: false))
        }
        states.append(.init(id: workflow.finishId, isStart: false, isFinish: true))
        return states
    }

    private func buildTransitions(from workflow: AnyWorkflow) -> [WorkflowGraph.Transition] {
        workflow.anyTransitions.map { transition in
            let isSubflow = transition.process is any AnyWorkflow
            let metadata: TransitionMetadata
            if isSubflow, let subworkflow = transition.process as? any AnyWorkflow & DataBindable & Defaultable {
                metadata = collectDataBindableMetadata(subworkflow, processId: transition.process.id)
            } else {
                metadata = transition.process.collectMetadata()
            }

            return WorkflowGraph.Transition(
                id: transition.id,
                from: transition.from,
                to: transition.to,
                processId: transition.process.id,
                trigger: transition.trigger,
                metadata: metadata,
                isSubflow: isSubflow
            )
        }
    }

    private func collectWorkflowIO(_ workflow: AnyWorkflow) -> (inputKeys: Set<String>, outputKeys: Set<String>) {
        guard let bindable = workflow as? any DataBindable & Defaultable else {
            return ([], [])
        }
        let metadata = collectDataBindableMetadata(bindable, processId: workflow.id)
        return (metadata.inputKeys, metadata.outputKeys)
    }

    private func collectDataBindableMetadata(
        _ bindable: any DataBindable & Defaultable,
        processId: TransitionProcessID
    ) -> TransitionMetadata {
        var instance = bindable
        var collector = CollectMetadata()
        try? instance.bind(&collector)
        return collector.metadata(processId: processId)
    }
}
