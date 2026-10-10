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
        var conflictingTypes: [String: [String]] = [:]
        var keysWithConflictingTypes: Set<String> = []
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
        dataAtState[state]?.conflictingTypes ?? [:]
    }

    /// Keys with a conflict here or at a state before, so consumers are not reported a second time.
    func hasConflictingTypes(_ key: String, at state: StateID) -> Bool {
        dataAtState[state]?.keysWithConflictingTypes.contains(key) ?? false
    }

    func keysMissingOnSomeBranches(at state: StateID) -> Set<String> {
        dataAtState[state]?.keysMissingOnSomeBranches ?? []
    }

    private func merged(from incoming: [WorkflowGraph.Transition]) -> StateData {
        let branches = incoming.map { transition -> (types: TypeMap, conflicted: Set<String>) in
            var types = types(at: transition.from)
            var conflicted = dataAtState[transition.from]?.keysWithConflictingTypes ?? []
            for output in transition.metadata.outputs {
                types[output.key] = output.valueType
                conflicted.remove(output.key)
            }
            return (types, conflicted)
        }
        let keysOnAnyBranch = Set(branches.flatMap(\.types.keys))
        let keysOnEveryBranch = keysOnAnyBranch.filter { key in
            branches.allSatisfy { $0.types[key] != nil }
        }

        var data = StateData(keysMissingOnSomeBranches: keysOnAnyBranch.subtracting(keysOnEveryBranch))
        for key in keysOnEveryBranch {
            let typesAcrossBranches = Set(branches.compactMap { $0.types[key] }).sorted()
            data.types[key] = typesAcrossBranches.first
            if typesAcrossBranches.count > 1 {
                data.conflictingTypes[key] = typesAcrossBranches
                data.keysWithConflictingTypes.insert(key)
            } else if branches.contains(where: { $0.conflicted.contains(key) }) {
                data.keysWithConflictingTypes.insert(key)
            }
        }
        return data
    }
}
