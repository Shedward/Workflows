//
//  WorkflowGraphBuilder.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowGraphBuilder: Sendable {
    private var graphCache: [WorkflowID: WorkflowGraph] = [:]
    private var analysisCache: [WorkflowID: DataFlowAnalyzer.Analysis] = [:]

    public init() {}

    public mutating func build(from workflow: AnyWorkflow) -> WorkflowGraph {
        if let cached = graphCache[workflow.id] {
            return cached
        }

        let states = buildStates(from: workflow)
        let transitions = buildTransitions(from: workflow)

        let declaredIO = collectWorkflowIO(workflow)

        let context = DataFlowAnalyzer.Context(
            transitions: transitions,
            states: states,
            declaredInputs: declaredIO.inputs,
            declaredOutputs: declaredIO.outputs,
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

        graphCache[workflow.id] = graph
        analysisCache[workflow.id] = analysis
        return graph
    }

    func analysis(for workflowId: WorkflowID) -> DataFlowAnalyzer.Analysis? {
        analysisCache[workflowId]
    }

    func cachedGraph(for workflowId: WorkflowID) -> WorkflowGraph? {
        graphCache[workflowId]
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
            let subworkflow = transition.process as? AnyWorkflow
            let metadata: TransitionMetadata
            if let bindableSubflow = subworkflow as? any AnyWorkflow & DataBindable & Defaultable {
                metadata = collectDataBindableMetadata(bindableSubflow, processId: transition.process.id)
            } else {
                metadata = transition.process.collectMetadata()
            }

            return WorkflowGraph.Transition(
                id: transition.id,
                from: transition.from,
                targets: transition.targets,
                processId: transition.process.id,
                trigger: transition.trigger,
                metadata: metadata,
                subflowId: subworkflow?.id
            )
        }
    }

    private func collectWorkflowIO(
        _ workflow: AnyWorkflow
    ) -> (inputs: Set<DataField>, outputs: Set<DataField>) {
        guard let bindable = workflow as? any DataBindable & Defaultable else {
            return ([], [])
        }
        let metadata = collectDataBindableMetadata(bindable, processId: workflow.id)
        return (metadata.inputs, metadata.outputs)
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
