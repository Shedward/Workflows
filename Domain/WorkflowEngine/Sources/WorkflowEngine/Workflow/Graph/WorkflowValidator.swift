//
//  WorkflowValidator.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowValidator: Sendable {

    /// Validates one workflow. Subflows must have been validated with the same `graphBuilder`
    /// before, so their required inputs are known.
    public static func validate(
        workflow: AnyWorkflow,
        dependencies: DependenciesContainer,
        graphBuilder: inout WorkflowGraphBuilder
    ) -> WorkflowValidationResult {
        let built = graphBuilder.built(from: workflow)
        let registeredKeys = dependencies.keys

        var errors = built.analysis.errors

        for transition in built.graph.transitions {
            for dep in transition.metadata.dependencies where !registeredKeys.contains(dep.key) {
                errors.append(.missingDependency(
                    key: dep.key,
                    valueType: dep.valueType,
                    processId: transition.processId
                ))
            }
        }

        for transition in built.graph.transitions {
            guard let subflowId = transition.subflowId else {
                continue
            }

            let availableKeys = Set((built.analysis.typeAtState[transition.from] ?? [:]).keys)
            let requiredInputs = graphBuilder.cachedGraph(for: subflowId)?.requiredInputs ?? []

            for field in requiredInputs where !availableKeys.contains(field.key) {
                errors.append(.unsatisfiedSubflowInput(
                    key: field.key,
                    subflowId: subflowId,
                    atState: transition.from
                ))
            }
        }

        for provider in workflow.providers {
            let providerType = String(describing: type(of: provider))
            let declared = provider.declaredMetadata(processId: providerType)

            for dep in declared.dependencies where !registeredKeys.contains(dep.key) {
                errors.append(.missingProviderDependency(
                    key: dep.key,
                    valueType: dep.valueType,
                    providerType: providerType
                ))
            }
        }

        return WorkflowValidationResult(
            workflowId: workflow.id,
            errors: errors,
            warnings: built.analysis.warnings
        )
    }
}
