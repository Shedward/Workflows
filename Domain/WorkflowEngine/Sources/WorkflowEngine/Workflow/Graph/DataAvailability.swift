//
//  DataAvailability.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 29.03.2026.
//

/// Which keys, of which types, are available at each reachable state. A key is available at a
/// state only if every incoming transition provides it.
struct DataAvailability: Sendable {
    typealias TypeMap = [String: String]

    private struct StateData: Sendable {
        var types: TypeMap = [:]
        var conflictsFoundHere: [String: [String]] = [:]
        var conflictedKeys: Set<String> = []
        var keysMissingOnSomeBranches: Set<String> = []
    }

    private var dataAtState: [StateID: StateData] = [:]

    init(in topology: GraphTopology, declaredInputs: Set<DataField>) {
        dataAtState[topology.start] = StateData(
            types: TypeMap(declaredInputs.map { ($0.key, $0.valueType) }, uniquingKeysWith: { first, _ in first })
        )

        for state in topology.reachableInTopologicalOrder where state != topology.start {
            let incoming = topology.transitionsNotClosingCycle(to: state).filter { topology.reachable.contains($0.from) }
            dataAtState[state] = merged(from: incoming)
        }
    }

    func types(at state: StateID) -> TypeMap {
        dataAtState[state]?.types ?? [:]
    }

    /// Keys whose branches disagree on the type at this state; reported once, here.
    func conflictingTypes(at state: StateID) -> [String: [String]] {
        dataAtState[state]?.conflictsFoundHere ?? [:]
    }

    /// Keys with a conflict here or at a state before, so consumers are not reported a second time.
    func hasConflictingTypes(_ key: String, at state: StateID) -> Bool {
        dataAtState[state]?.conflictedKeys.contains(key) ?? false
    }

    func keysMissingOnSomeBranches(at state: StateID) -> Set<String> {
        dataAtState[state]?.keysMissingOnSomeBranches ?? []
    }

    private func merged(from incoming: [WorkflowGraph.Transition]) -> StateData {
        let branches = incoming.map { transition -> (types: TypeMap, conflictedKeys: Set<String>) in
            var types = types(at: transition.from)
            var conflictedKeys = dataAtState[transition.from]?.conflictedKeys ?? []
            for output in transition.metadata.outputs {
                types[output.key] = output.valueType
                conflictedKeys.remove(output.key)
            }
            return (types, conflictedKeys)
        }
        let keysOnAnyBranch = Set(branches.flatMap(\.types.keys))
        let keysOnEveryBranch = keysOnAnyBranch.filter { key in
            branches.allSatisfy { $0.types[key] != nil }
        }

        var data = StateData(keysMissingOnSomeBranches: keysOnAnyBranch.subtracting(keysOnEveryBranch))
        for key in keysOnEveryBranch {
            let typesAcrossBranches = Set(branches.compactMap { $0.types[key] }).sorted()
            data.types[key] = typesAcrossBranches[0]
            if typesAcrossBranches.count > 1 {
                data.conflictsFoundHere[key] = typesAcrossBranches
                data.conflictedKeys.insert(key)
            } else if branches.contains(where: { $0.conflictedKeys.contains(key) }) {
                data.conflictedKeys.insert(key)
            }
        }
        return data
    }
}
