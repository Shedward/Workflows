//
//  WorkflowValidator.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

public struct WorkflowValidator: Sendable {

    /// Validates one workflow. `graphBuilder` caches the graphs built along the way.
    public static func validate(
        workflow: AnyWorkflow,
        dependencies: DependenciesContainer,
        graphBuilder: inout WorkflowGraphBuilder
    ) -> WorkflowValidationResult {
        let graph = graphBuilder.build(from: workflow)
        let topology = GraphTopology(transitions: graph.transitions, start: workflow.startId)
        let validator = WorkflowValidator(
            workflow: workflow,
            graph: graph,
            declaredOutputs: workflow.declaredMetadata.outputs,
            topology: topology,
            availability: DataAvailability(in: topology, declaredInputs: graph.requiredInputs),
            registeredDependencies: dependencies.keys
        )

        return WorkflowValidationResult(
            workflowId: workflow.id,
            errors: validator.errors,
            warnings: validator.warnings
        )
    }

    private let workflow: AnyWorkflow
    private let graph: WorkflowGraph
    private let declaredOutputs: Set<DataField>
    private let topology: GraphTopology
    private let availability: DataAvailability
    private let registeredDependencies: Set<String>

    private var errors: [ValidationError] {
        let checks = [
            automaticCyclesWithoutExit,
            unreachableFinish,
            deadEndStates,
            conflictsBetweenBranches,
            unsatisfiedInputs,
            declaredOutputsNotProduced,
            missingDependencies,
            unsatisfiedSubflowInputs,
            missingProviderDependencies
        ]
        return Array(checks.joined())
    }

    private var warnings: [ValidationWarning] {
        let checks = [
            cycles,
            unreachableStates,
            ambiguousAutomaticTransitions,
            unusedInputs
        ]
        return Array(checks.joined())
    }
}

// MARK: - Structure

private extension WorkflowValidator {
    var cycles: [ValidationWarning] {
        topology.cycles.map { .cycleDetected($0) }
    }

    var automaticCyclesWithoutExit: [ValidationError] {
        topology.cycles
            .filter { cycle in
                let transitionsFromCycle = cycle.flatMap { topology.transitions(from: $0) }
                let hasManualExit = transitionsFromCycle.contains { transition in
                    transition.trigger == .manual && transition.targets.contains { !cycle.contains($0) }
                }
                return !hasManualExit
            }
            .map { .automaticCycleWithoutExit($0) }
    }

    var unreachableFinish: [ValidationError] {
        topology.reachable.contains(workflow.finishId) ? [] : [.unreachableFinish]
    }

    var unreachableStates: [ValidationWarning] {
        graph.states
            .filter { !$0.isStart && !$0.isFinish && !topology.reachable.contains($0.id) }
            .map { .unreachableState($0.id) }
    }

    var deadEndStates: [ValidationError] {
        graph.states
            .filter { !$0.isFinish && topology.reachable.contains($0.id) && topology.transitions(from: $0.id).isEmpty }
            .map { .deadEndState($0.id) }
    }

    var ambiguousAutomaticTransitions: [ValidationWarning] {
        graph.states.compactMap { state in
            let automaticCount = topology.transitions(from: state.id).filter { $0.trigger == .automatic }.count
            return automaticCount > 1 ? .ambiguousAutomaticTransitions(state: state.id, count: automaticCount) : nil
        }
    }
}

// MARK: - Data flow

private extension WorkflowValidator {
    var conflictsBetweenBranches: [ValidationError] {
        var errors: [ValidationError] = []
        for state in topology.reachableInTopologicalOrder {
            for (key, types) in availability.conflictingTypes(at: state).sorted(by: { $0.key < $1.key }) {
                errors.append(.typeMismatch(key: key, types: types, atState: state))
            }

            let keysMissingOnSomeBranches = availability.keysMissingOnSomeBranches(at: state)
            for transition in topology.transitions(from: state) {
                for key in transition.metadata.inputKeys where keysMissingOnSomeBranches.contains(key) {
                    errors.append(.conditionallyAvailableInput(key: key, processId: transition.processId, atState: state))
                }
            }
        }
        return errors
    }

    var unsatisfiedInputs: [ValidationError] {
        let declaredInputKeys = Set(graph.requiredInputs.map(\.key))

        var errors: [ValidationError] = []
        for transition in graph.transitions where topology.reachable.contains(transition.from) {
            let availableTypes = availability.types(at: transition.from)
            let reportedAsConditional = availability.keysMissingOnSomeBranches(at: transition.from)
            let reportedAsSubflowInput = transition.subflowId != nil

            for input in transition.metadata.inputs {
                if let availableType = availableTypes[input.key] {
                    if availableType != input.valueType, !availability.hasConflictingTypes(input.key, at: transition.from) {
                        errors.append(.inputTypeMismatch(
                            key: input.key,
                            processId: transition.processId,
                            expected: input.valueType,
                            available: availableType,
                            atState: transition.from
                        ))
                    }
                } else if !declaredInputKeys.contains(input.key), !reportedAsConditional.contains(input.key), !reportedAsSubflowInput {
                    errors.append(.undeclaredWorkflowInput(key: input.key, processId: transition.processId))
                }
            }
        }
        return errors
    }

    var declaredOutputsNotProduced: [ValidationError] {
        let typesAtFinish = availability.types(at: workflow.finishId)
        var errors: [ValidationError] = []
        for output in declaredOutputs {
            if let produced = typesAtFinish[output.key] {
                if produced != output.valueType {
                    errors.append(.outputTypeMismatch(key: output.key, declared: output.valueType, produced: produced))
                }
            } else {
                errors.append(.undeclaredWorkflowOutput(key: output.key))
            }
        }
        return errors
    }

    var unusedInputs: [ValidationWarning] {
        let consumedKeys = Set(graph.transitions.flatMap(\.metadata.inputKeys))
        return Set(graph.requiredInputs.map(\.key))
            .subtracting(consumedKeys)
            .map { .unusedWorkflowInput(key: $0) }
    }
}

// MARK: - Dependencies and subflows

private extension WorkflowValidator {
    var missingDependencies: [ValidationError] {
        graph.transitions.flatMap { transition in
            transition.metadata.dependencies
                .filter { !registeredDependencies.contains($0.key) }
                .map { .missingDependency(key: $0.key, valueType: $0.valueType, processId: transition.processId) }
        }
    }

    var unsatisfiedSubflowInputs: [ValidationError] {
        var errors: [ValidationError] = []
        for transition in graph.transitions {
            guard let subflowId = transition.subflowId else {
                continue
            }

            let availableTypes = availability.types(at: transition.from)

            for field in transition.metadata.inputs where availableTypes[field.key] == nil {
                errors.append(.unsatisfiedSubflowInput(
                    key: field.key,
                    subflowId: subflowId,
                    atState: transition.from
                ))
            }
        }
        return errors
    }

    var missingProviderDependencies: [ValidationError] {
        var errors: [ValidationError] = []
        for provider in workflow.providers {
            let providerType = String(describing: type(of: provider))
            let declared = provider.declaredMetadata(processId: providerType)

            for dependency in declared.dependencies where !registeredDependencies.contains(dependency.key) {
                errors.append(.missingProviderDependency(
                    key: dependency.key,
                    valueType: dependency.valueType,
                    providerType: providerType
                ))
            }
        }
        return errors
    }
}
