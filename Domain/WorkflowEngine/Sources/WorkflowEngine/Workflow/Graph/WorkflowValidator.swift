//
//  WorkflowValidator.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowValidator: Sendable {

    public static func validate(
        workflow: AnyWorkflow,
        dependencies: DependenciesContainer,
        graphBuilder: inout WorkflowGraphBuilder
    ) -> WorkflowValidationResult {
        let graph = graphBuilder.build(from: workflow)

        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []

        let registeredKeys = dependencies.keys
        for transition in graph.transitions {
            for dep in transition.metadata.dependencies where !registeredKeys.contains(dep.key) {
                errors.append(.missingDependency(
                    key: dep.key,
                    valueType: dep.valueType,
                    processId: transition.processId
                ))
            }
        }

        let declaredIO = collectWorkflowIO(workflow)
        let context = DataFlowAnalyzer.Context(
            transitions: graph.transitions,
            states: graph.states,
            declaredInputKeys: declaredIO.inputKeys,
            declaredOutputKeys: declaredIO.outputKeys,
            startId: graph.states.first(where: \.isStart)?.id ?? "_start",
            finishId: graph.states.first(where: \.isFinish)?.id ?? "_finish"
        )
        let analysis = DataFlowAnalyzer.analyze(context)
        errors.append(contentsOf: analysis.errors)
        warnings.append(contentsOf: analysis.warnings)

        return WorkflowValidationResult(
            workflowId: workflow.id,
            errors: errors,
            warnings: warnings
        )
    }

    private static func collectWorkflowIO(
        _ workflow: AnyWorkflow
    ) -> (inputKeys: Set<String>, outputKeys: Set<String>) {
        guard let bindable = workflow as? any DataBindable & Defaultable else {
            return ([], [])
        }
        var instance = bindable
        var collector = CollectMetadata()
        try? instance.bind(&collector)
        return (
            Set(collector.inputs.map(\.key)),
            Set(collector.outputs.map(\.key))
        )
    }
}
