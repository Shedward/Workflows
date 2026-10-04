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
        var keysMissingOnSomeBranches: Set<String> = []
    }

    private var dataAtState: [StateID: StateData] = [:]

    init(in topology: GraphTopology, declaredInputs: Set<DataField>) {
        dataAtState[topology.start] = StateData(
            types: TypeMap(declaredInputs.map { ($0.key, $0.valueType) }, uniquingKeysWith: { first, _ in first })
        )

        for state in topology.reachableInTopologicalOrder where state != topology.start {
            dataAtState[state] = merged(from: topology.transitionsNotClosingCycle(to: state))
        }
    }

    func types(at state: StateID) -> TypeMap {
        dataAtState[state]?.types ?? [:]
    }

    func conflictingTypes(at state: StateID) -> [String: [String]] {
        dataAtState[state]?.conflictingTypes ?? [:]
    }

    func keysMissingOnSomeBranches(at state: StateID) -> Set<String> {
        dataAtState[state]?.keysMissingOnSomeBranches ?? []
    }

    private func merged(from incoming: [WorkflowGraph.Transition]) -> StateData {
        let branches = incoming.map { transition in
            types(at: transition.from).merging(
                transition.metadata.outputs.map { ($0.key, $0.valueType) },
                uniquingKeysWith: { _, produced in produced }
            )
        }
        let keysOnAnyBranch = Set(branches.flatMap(\.keys))
        let keysOnEveryBranch = keysOnAnyBranch.filter { key in
            branches.allSatisfy { $0[key] != nil }
        }

        var data = StateData(keysMissingOnSomeBranches: keysOnAnyBranch.subtracting(keysOnEveryBranch))
        for key in keysOnEveryBranch {
            let typesAcrossBranches = Set(branches.compactMap { $0[key] }).sorted()
            data.types[key] = typesAcrossBranches.first
            if typesAcrossBranches.count > 1 {
                data.conflictingTypes[key] = typesAcrossBranches
            }
        }
        return data
    }
}
