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
        let analysis = graphBuilder.analysis(for: workflow.id)

        var errors: [ValidationError] = analysis?.errors ?? []
        let warnings: [ValidationWarning] = analysis?.warnings ?? []

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

        validateSubflowInputs(
            graph: graph,
            analysis: analysis,
            graphBuilder: &graphBuilder,
            errors: &errors
        )

        validateProviderDependencies(
            workflow: workflow,
            dependencies: dependencies,
            errors: &errors
        )

        return WorkflowValidationResult(
            workflowId: workflow.id,
            errors: errors,
            warnings: warnings
        )
    }

    private static func validateProviderDependencies(
        workflow: AnyWorkflow,
        dependencies: DependenciesContainer,
        errors: inout [ValidationError]
    ) {
        let registeredKeys = dependencies.keys

        for provider in workflow.providers {
            var provider = provider
            var collector = CollectMetadata()
            try? provider.bind(&collector)

            let providerType = String(describing: type(of: provider))
            for dep in collector.dependencies where !registeredKeys.contains(dep.key) {
                errors.append(.missingProviderDependency(
                    key: dep.key,
                    valueType: dep.valueType,
                    providerType: providerType
                ))
            }
        }
    }

    private static func validateSubflowInputs(
        graph: WorkflowGraph,
        analysis: DataFlowAnalyzer.Analysis?,
        graphBuilder: inout WorkflowGraphBuilder,
        errors: inout [ValidationError]
    ) {
        guard let typeAtState = analysis?.typeAtState else {
            return
        }

        for transition in graph.transitions where transition.subflowId != nil {
            guard let subflowId = transition.subflowId else {
                continue
            }

            let parentAvailableKeys = Set((typeAtState[transition.from] ?? [:]).keys)
            let subflowGraph = graphBuilder.cachedGraph(for: subflowId)
            let subflowRequiredKeys = subflowGraph?.requiredInputs ?? []

            for field in subflowRequiredKeys where !parentAvailableKeys.contains(field.key) {
                errors.append(.unsatisfiedSubflowInput(
                    key: field.key,
                    subflowId: subflowId,
                    atState: transition.from
                ))
            }
        }
    }
}
