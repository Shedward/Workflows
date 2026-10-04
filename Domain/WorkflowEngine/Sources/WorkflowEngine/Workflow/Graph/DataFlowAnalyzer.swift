//
//  DataFlowAnalyzer.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

/// Static analysis of one workflow graph: structure (reachability, cycles, dead ends) and
/// data flow (which keys, of which types, are available at each state).
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

    private struct BackEdgeKey: Hashable {
        let from: StateID
        let to: StateID
        let processId: TransitionProcessID
    }

    static func analyze(_ context: Context) -> Analysis {
        var analyzer = DataFlowAnalyzer(context)
        analyzer.checkStructure()
        analyzer.propagateDataFlow()
        analyzer.validateInputs()
        return analyzer.analysis
    }

    private let context: Context
    private let outgoing: [StateID: [WorkflowGraph.Transition]]
    private let incoming: [StateID: [WorkflowGraph.Transition]]
    /// States reachable from start, in topological order (back edges ignored).
    private let order: [StateID]
    private let backEdges: [BackEdgeInfo]
    private let reachableStates: Set<StateID>

    private var typeAtState: [StateID: TypeMap] = [:]
    private var conflictedKeys: [StateID: Set<String>] = [:]
    private var errors: [ValidationError] = []
    private var warnings: [ValidationWarning] = []

    private var analysis: Analysis {
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

    private init(_ context: Context) {
        var outgoing: [StateID: [WorkflowGraph.Transition]] = [:]
        var incoming: [StateID: [WorkflowGraph.Transition]] = [:]
        for transition in context.transitions {
            outgoing[transition.from, default: []].append(transition)
            for target in transition.targets {
                incoming[target, default: []].append(transition)
            }
        }

        let (order, backEdges) = Self.topologicalOrder(from: context.startId, outgoing: outgoing)

        self.context = context
        self.outgoing = outgoing
        self.incoming = incoming
        self.order = order
        self.backEdges = backEdges
        self.reachableStates = Set(order)
    }
}

// MARK: - Structure

private extension DataFlowAnalyzer {
    mutating func checkStructure() {
        for backEdge in backEdges {
            let cyclePath = backEdge.cyclePath
            let cycleSet = Set(cyclePath)
            warnings.append(.cycleDetected(cyclePath))

            let hasExit = cyclePath.contains { stateId in
                (outgoing[stateId] ?? []).contains { $0.trigger == .manual && $0.targets.contains { !cycleSet.contains($0) } }
            }
            if !hasExit {
                errors.append(.automaticCycleWithoutExit(cyclePath))
            }
        }

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

// MARK: - Data flow

private extension DataFlowAnalyzer {
    /// Walks the states in topological order. A key is available at a state only if every
    /// incoming edge provides it.
    mutating func propagateDataFlow() {
        typeAtState[context.startId] = TypeMap(
            context.declaredInputs.map { ($0.key, $0.valueType) },
            uniquingKeysWith: { first, _ in first }
        )

        let backEdgeKeys = Set(
            backEdges.map {
                BackEdgeKey(from: $0.transition.from, to: $0.target, processId: $0.transition.processId)
            }
        )

        for stateId in order where stateId != context.startId {
            let incomingEdges = (incoming[stateId] ?? []).filter { edge in
                !backEdgeKeys.contains(BackEdgeKey(from: edge.from, to: stateId, processId: edge.processId))
            }
            propagate(to: stateId, through: incomingEdges)
        }
    }

    mutating func propagate(to stateId: StateID, through incomingEdges: [WorkflowGraph.Transition]) {
        guard !incomingEdges.isEmpty else {
            typeAtState[stateId] = [:]
            return
        }

        let typeContributions = incomingEdges.map { edge -> TypeMap in
            var edgeTypes = typeAtState[edge.from] ?? [:]
            for output in edge.metadata.outputs {
                edgeTypes[output.key] = output.valueType
            }
            return edgeTypes
        }

        let contributions = typeContributions.map { Set($0.keys) }
        let intersection = contributions.dropFirst().reduce(contributions[0]) { $0.intersection($1) }

        typeAtState[stateId] = mergeTypes(of: intersection, from: typeContributions, at: stateId)

        checkConditionalInputs(at: stateId, contributions: contributions, intersection: intersection)
    }

    /// One type per key. Keys the incoming edges disagree on are reported and remembered,
    /// so their consumers are not reported a second time.
    mutating func mergeTypes(of keys: Set<String>, from typeContributions: [TypeMap], at stateId: StateID) -> TypeMap {
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
        if !conflicted.isEmpty {
            conflictedKeys[stateId] = conflicted
        }
        return mergedTypes
    }

    mutating func checkConditionalInputs(at stateId: StateID, contributions: [Set<String>], intersection: Set<String>) {
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

// MARK: - Inputs and outputs

private extension DataFlowAnalyzer {
    mutating func validateInputs() {
        let declaredInputKeys = Set(context.declaredInputs.map(\.key))
        let allConsumedKeys = Set(context.transitions.flatMap(\.metadata.inputKeys))

        for transition in context.transitions where reachableStates.contains(transition.from) {
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
