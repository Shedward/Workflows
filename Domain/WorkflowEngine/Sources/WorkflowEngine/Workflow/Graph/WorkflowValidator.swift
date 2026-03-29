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
        var warnings: [ValidationWarning] = analysis?.warnings ?? []

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

        return WorkflowValidationResult(
            workflowId: workflow.id,
            errors: errors,
            warnings: warnings
        )
    }
}
