//
//  DataFlowAnalyzer.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

// swiftlint:disable:next convenience_type
struct DataFlowAnalyzer {
    typealias TypeMap = [String: String]

    struct Context {
        let transitions: [WorkflowGraph.Transition]
        let states: [WorkflowGraph.State]
        let declaredInputs: Set<DataField>
        let declaredOutputs: Set<DataField>
        let startId: StateID
        let finishId: StateID
    }

    struct Analysis: Sendable {
        let requiredInputs: Set<DataField>
        let producedOutputs: Set<DataField>
        let typeAtState: [StateID: TypeMap]
        let conflictedKeys: [StateID: Set<String>]
        let errors: [ValidationError]
        let warnings: [ValidationWarning]
    }

    static func analyze(_ context: Context) -> Analysis {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []

        let adjacency = Adjacency(transitions: context.transitions)
        let (order, backEdges) = topologicalOrder(
            from: context.startId,
            outgoing: adjacency.outgoing
        )

        checkStructure(
            context: context,
            order: order,
            backEdges: backEdges,
            outgoing: adjacency.outgoing,
            errors: &errors,
            warnings: &warnings
        )

        let reachableStates = Set(order)
        var conflictedKeys: [StateID: Set<String>] = [:]
        let typeAtState = propagateDataFlow(
            context: context,
            order: order,
            adjacency: adjacency,
            backEdges: backEdges,
            conflictedKeys: &conflictedKeys,
            errors: &errors
        )

        validateInputs(
            context: context,
            typeAtState: typeAtState,
            conflictedKeys: conflictedKeys,
            reachableStates: reachableStates,
            errors: &errors,
            warnings: &warnings
        )

        let declaredOutputKeys = Set(context.declaredOutputs.map(\.key))
        let producedOutputs = Set(
            (typeAtState[context.finishId] ?? [:])
                .filter { declaredOutputKeys.contains($0.key) }
                .map { DataField(key: $0.key, valueType: $0.value) }
        )

        return Analysis(
            requiredInputs: context.declaredInputs,
            producedOutputs: producedOutputs,
            typeAtState: typeAtState,
            conflictedKeys: conflictedKeys,
            errors: errors,
            warnings: warnings
        )
    }
}

// MARK: - Adjacency

private extension DataFlowAnalyzer {
    struct Adjacency {
        let outgoing: [StateID: [WorkflowGraph.Transition]]
        let incoming: [StateID: [WorkflowGraph.Transition]]

        init(transitions: [WorkflowGraph.Transition]) {
            var outgoing: [StateID: [WorkflowGraph.Transition]] = [:]
            var incoming: [StateID: [WorkflowGraph.Transition]] = [:]
            for transition in transitions {
                outgoing[transition.from, default: []].append(transition)
                incoming[transition.to, default: []].append(transition)
            }
            self.outgoing = outgoing
            self.incoming = incoming
        }
    }

    struct BackEdgeKey: Hashable {
        let from: StateID
        let to: StateID
        let processId: TransitionProcessID
    }
}

// MARK: - Structural Checks

private extension DataFlowAnalyzer {
    // swiftlint:disable:next function_parameter_count
    static func checkStructure(
        context: Context,
        order: [StateID],
        backEdges: [BackEdgeInfo],
        outgoing: [StateID: [WorkflowGraph.Transition]],
        errors: inout [ValidationError],
        warnings: inout [ValidationWarning]
    ) {
        for backEdge in backEdges {
            let cyclePath = backEdge.cyclePath
            let cycleSet = Set(cyclePath)
            warnings.append(.cycleDetected(cyclePath))

            let hasExit = cyclePath.contains { stateId in
                (outgoing[stateId] ?? []).contains { $0.trigger == .manual && !cycleSet.contains($0.to) }
            }
            if !hasExit {
                errors.append(.automaticCycleWithoutExit(cyclePath))
            }
        }

        let reachableStates = Set(order)
        if !reachableStates.contains(context.finishId) {
            errors.append(.unreachableFinish)
        }

        for state in context.states where !state.isStart && !state.isFinish && !reachableStates.contains(state.id) {
            warnings.append(.unreachableState(state.id))
        }

        for state in context.states
            where !state.isFinish && reachableStates.contains(state.id) && (outgoing[state.id] ?? []).isEmpty {
            errors.append(.deadEndState(state.id))
        }

        for (stateId, stateTransitions) in outgoing {
            let automaticCount = stateTransitions.filter { $0.trigger == .automatic }.count
            if automaticCount > 1 {
                warnings.append(.ambiguousAutomaticTransitions(state: stateId, count: automaticCount))
            }
        }
    }
}

// MARK: - Data Flow Propagation

private extension DataFlowAnalyzer {
    // swiftlint:disable:next function_parameter_count
    static func propagateDataFlow(
        context: Context,
        order: [StateID],
        adjacency: Adjacency,
        backEdges: [BackEdgeInfo],
        conflictedKeys: inout [StateID: Set<String>],
        errors: inout [ValidationError]
    ) -> [StateID: TypeMap] {
        var types: [StateID: TypeMap] = [:]

        types[context.startId] = TypeMap(
            context.declaredInputs.map { ($0.key, $0.valueType) },
            uniquingKeysWith: { first, _ in first }
        )

        let backEdgeSet = Set(
            backEdges.map {
                BackEdgeKey(from: $0.transition.from, to: $0.transition.to, processId: $0.transition.processId)
            }
        )

        for stateId in order where stateId != context.startId {
            let incomingEdges = (adjacency.incoming[stateId] ?? []).filter { edge in
                !backEdgeSet.contains(BackEdgeKey(from: edge.from, to: edge.to, processId: edge.processId))
            }

            propagateState(
                stateId: stateId,
                incomingEdges: incomingEdges,
                types: &types,
                conflictedKeys: &conflictedKeys,
                outgoing: adjacency.outgoing,
                errors: &errors
            )
        }

        return types
    }

    // swiftlint:disable:next function_parameter_count
    static func propagateState(
        stateId: StateID,
        incomingEdges: [WorkflowGraph.Transition],
        types: inout [StateID: TypeMap],
        conflictedKeys: inout [StateID: Set<String>],
        outgoing: [StateID: [WorkflowGraph.Transition]],
        errors: inout [ValidationError]
    ) {
        guard !incomingEdges.isEmpty else {
            types[stateId] = [:]
            return
        }

        let typeContributions = incomingEdges.map { edge -> TypeMap in
            var edgeTypes = types[edge.from] ?? [:]
            for output in edge.metadata.outputs {
                edgeTypes[output.key] = output.valueType
            }
            return edgeTypes
        }

        let contributions = typeContributions.map { Set($0.keys) }
        let intersection = contributions.dropFirst().reduce(contributions[0]) { $0.intersection($1) }

        let (mergedTypeMap, stateConflicts) = mergeTypes(
            keys: intersection,
            typeContributions: typeContributions,
            stateId: stateId,
            errors: &errors
        )
        types[stateId] = mergedTypeMap
        if !stateConflicts.isEmpty { conflictedKeys[stateId] = stateConflicts }

        checkConditionalInputs(
            stateId: stateId,
            contributions: contributions,
            intersection: intersection,
            outgoing: outgoing,
            errors: &errors
        )
    }

    static func mergeTypes(
        keys: Set<String>,
        typeContributions: [TypeMap],
        stateId: StateID,
        errors: inout [ValidationError]
    ) -> (TypeMap, conflicted: Set<String>) {
        var mergedTypes: TypeMap = [:]
        var conflicted: Set<String> = []
        for key in keys {
            let keyTypes = Set(typeContributions.compactMap { $0[key] })
            mergedTypes[key] = keyTypes.min() ?? ""
            if keyTypes.count > 1 {
                conflicted.insert(key)
                errors.append(.typeMismatch(key: key, types: keyTypes.sorted(), atState: stateId))
            }
        }
        return (mergedTypes, conflicted)
    }

    static func checkConditionalInputs(
        stateId: StateID,
        contributions: [Set<String>],
        intersection: Set<String>,
        outgoing: [StateID: [WorkflowGraph.Transition]],
        errors: inout [ValidationError]
    ) {
        guard contributions.count > 1 else {
            return
        }

        let conditionalKeys = contributions.reduce(Set<String>()) { $0.union($1) }.subtracting(intersection)

        for edge in outgoing[stateId] ?? [] {
            for inputKey in edge.metadata.inputKeys where conditionalKeys.contains(inputKey) {
                errors.append(.conditionallyAvailableInput(
                    key: inputKey,
                    processId: edge.processId,
                    atState: stateId
                ))
            }
        }
    }
}

// MARK: - Input Validation

private extension DataFlowAnalyzer {
    // swiftlint:disable:next function_parameter_count
    static func validateInputs(
        context: Context,
        typeAtState: [StateID: TypeMap],
        conflictedKeys: [StateID: Set<String>],
        reachableStates: Set<StateID>,
        errors: inout [ValidationError],
        warnings: inout [ValidationWarning]
    ) {
        let declaredInputKeys = Set(context.declaredInputs.map(\.key))
        let allConsumedKeys = Set(context.transitions.flatMap(\.metadata.inputKeys))

        for transition in context.transitions {
            guard reachableStates.contains(transition.from) else {
                continue
            }
            let stateTypes = typeAtState[transition.from] ?? [:]
            let stateConflicts = conflictedKeys[transition.from] ?? []

            for input in transition.metadata.inputs {
                if !stateTypes.keys.contains(input.key) {
                    if !declaredInputKeys.contains(input.key) {
                        errors.append(.undeclaredWorkflowInput(key: input.key, processId: transition.processId))
                    }
                } else if !stateConflicts.contains(input.key),
                          let availableType = stateTypes[input.key],
                          availableType != input.valueType {
                    errors.append(.typeMismatch(
                        key: input.key,
                        types: [availableType, input.valueType],
                        atState: transition.from
                    ))
                }
            }
        }

        let producedKeys = Set((typeAtState[context.finishId] ?? [:]).keys)
        for key in context.declaredOutputs.map(\.key) where !producedKeys.contains(key) {
            errors.append(.undeclaredWorkflowOutput(key: key))
        }

        for inputKey in declaredInputKeys where !allConsumedKeys.contains(inputKey) {
            warnings.append(.unusedWorkflowInput(key: inputKey))
        }
    }
}

// MARK: - Topological Sort

private extension DataFlowAnalyzer {
    typealias BackEdgeInfo = (transition: WorkflowGraph.Transition, cyclePath: [StateID])

    static func topologicalOrder(
        from start: StateID,
        outgoing: [StateID: [WorkflowGraph.Transition]]
    ) -> (order: [StateID], backEdges: [BackEdgeInfo]) {
        var visited: Set<StateID> = []
        var inStack: Set<StateID> = []
        var pathStack: [StateID] = []
        var order: [StateID] = []
        var backEdges: [BackEdgeInfo] = []

        func dfs(_ state: StateID) {
            guard !visited.contains(state) else {
                return
            }
            visited.insert(state)
            inStack.insert(state)
            pathStack.append(state)

            for transition in outgoing[state] ?? [] {
                if inStack.contains(transition.to) {
                    let cycleStart = pathStack.firstIndex(of: transition.to) ?? 0
                    let cyclePath = Array(pathStack[cycleStart...])
                    backEdges.append(BackEdgeInfo(transition: transition, cyclePath: cyclePath))
                } else if !visited.contains(transition.to) {
                    dfs(transition.to)
                }
            }

            pathStack.removeLast()
            inStack.remove(state)
            order.append(state)
        }

        dfs(start)
        order.reverse()
        return (order, backEdges)
    }
}
