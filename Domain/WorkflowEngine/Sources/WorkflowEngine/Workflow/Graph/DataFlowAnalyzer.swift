//
//  DataFlowAnalyzer.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

// swiftlint:disable:next convenience_type
struct DataFlowAnalyzer {

    struct Context {
        let transitions: [WorkflowGraph.Transition]
        let states: [WorkflowGraph.State]
        let declaredInputKeys: Set<String>
        let declaredOutputKeys: Set<String>
        let startId: StateID
        let finishId: StateID
    }

    struct Analysis: Sendable {
        let requiredInputs: Set<String>
        let producedOutputs: Set<String>
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
        let available = propagateDataFlow(
            context: context,
            order: order,
            adjacency: adjacency,
            backEdges: backEdges,
            errors: &errors
        )

        validateInputs(
            context: context,
            available: available,
            reachableStates: reachableStates,
            errors: &errors,
            warnings: &warnings
        )

        return Analysis(
            requiredInputs: context.declaredInputKeys,
            producedOutputs: available[context.finishId] ?? [],
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
        backEdges: [WorkflowGraph.Transition],
        outgoing: [StateID: [WorkflowGraph.Transition]],
        errors: inout [ValidationError],
        warnings: inout [ValidationWarning]
    ) {
        if !backEdges.isEmpty {
            let cycleStates = Array(Set(backEdges.flatMap { [$0.from, $0.to] }))
            warnings.append(.cycleDetected(cycleStates))
        }

        let reachableStates = Set(order)
        if !reachableStates.contains(context.finishId) {
            errors.append(.unreachableFinish)
        }

        for state in context.states where !state.isStart && !state.isFinish {
            if !reachableStates.contains(state.id) {
                warnings.append(.unreachableState(state.id))
            }
        }

        for state in context.states where !state.isFinish {
            if reachableStates.contains(state.id),
               (outgoing[state.id] ?? []).isEmpty {
                errors.append(.deadEndState(state.id))
            }
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
    static func propagateDataFlow(
        context: Context,
        order: [StateID],
        adjacency: Adjacency,
        backEdges: [WorkflowGraph.Transition],
        errors: inout [ValidationError]
    ) -> [StateID: Set<String>] {
        var available: [StateID: Set<String>] = [:]
        available[context.startId] = context.declaredInputKeys

        let backEdgeSet = Set(
            backEdges.map { BackEdgeKey(from: $0.from, to: $0.to, processId: $0.processId) }
        )

        for stateId in order where stateId != context.startId {
            let incomingEdges = (adjacency.incoming[stateId] ?? []).filter { edge in
                !backEdgeSet.contains(BackEdgeKey(from: edge.from, to: edge.to, processId: edge.processId))
            }

            guard !incomingEdges.isEmpty else {
                available[stateId] = []
                continue
            }

            let contributions = incomingEdges.map { edge in
                (available[edge.from] ?? []).union(edge.metadata.outputKeys)
            }

            var intersection = contributions[0]
            for contribution in contributions.dropFirst() {
                intersection.formIntersection(contribution)
            }
            available[stateId] = intersection

            checkConditionalInputs(
                stateId: stateId,
                contributions: contributions,
                intersection: intersection,
                outgoing: adjacency.outgoing,
                errors: &errors
            )
        }

        return available
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

        let union = contributions.reduce(Set<String>()) { $0.union($1) }
        let conditionalKeys = union.subtracting(intersection)

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
    static func validateInputs(
        context: Context,
        available: [StateID: Set<String>],
        reachableStates: Set<StateID>,
        errors: inout [ValidationError],
        warnings: inout [ValidationWarning]
    ) {
        let allConsumedKeys = context.transitions.reduce(into: Set<String>()) {
            $0.formUnion($1.metadata.inputKeys)
        }

        for transition in context.transitions {
            guard reachableStates.contains(transition.from) else {
                continue
            }
            let stateAvailable = available[transition.from] ?? []

            for inputKey in transition.metadata.inputKeys where !stateAvailable.contains(inputKey) {
                if !context.declaredInputKeys.contains(inputKey) {
                    errors.append(.undeclaredWorkflowInput(key: inputKey, processId: transition.processId))
                }
            }
        }

        let producedOutputs = available[context.finishId] ?? []
        for outputKey in context.declaredOutputKeys where !producedOutputs.contains(outputKey) {
            errors.append(.undeclaredWorkflowOutput(key: outputKey))
        }

        for inputKey in context.declaredInputKeys where !allConsumedKeys.contains(inputKey) {
            warnings.append(.unusedWorkflowInput(key: inputKey))
        }
    }
}

// MARK: - Topological Sort

private extension DataFlowAnalyzer {
    static func topologicalOrder(
        from start: StateID,
        outgoing: [StateID: [WorkflowGraph.Transition]]
    ) -> (order: [StateID], backEdges: [WorkflowGraph.Transition]) {
        var visited: Set<StateID> = []
        var inStack: Set<StateID> = []
        var order: [StateID] = []
        var backEdges: [WorkflowGraph.Transition] = []

        func dfs(_ state: StateID) {
            guard !visited.contains(state) else {
                return
            }
            visited.insert(state)
            inStack.insert(state)

            for transition in outgoing[state] ?? [] {
                if inStack.contains(transition.to) {
                    backEdges.append(transition)
                } else if !visited.contains(transition.to) {
                    dfs(transition.to)
                }
            }

            inStack.remove(state)
            order.append(state)
        }

        dfs(start)
        order.reverse()
        return (order, backEdges)
    }
}
