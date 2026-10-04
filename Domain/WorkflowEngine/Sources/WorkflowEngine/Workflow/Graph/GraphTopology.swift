//
//  GraphTopology.swift
//  WorkflowEngine
//

struct GraphTopology: Sendable {
    private struct Edge: Hashable {
        let from: StateID
        let to: StateID
    }

    let start: StateID
    let reachableInTopologicalOrder: [StateID]
    let reachable: Set<StateID>
    let cycles: [[StateID]]

    private let transitions: [WorkflowGraph.Transition]
    private let outgoing: [StateID: [WorkflowGraph.Transition]]
    private let cycleClosingEdges: Set<Edge>

    init(transitions: [WorkflowGraph.Transition], start: StateID) {
        let outgoing = Dictionary(grouping: transitions, by: \.from)
        var visited: Set<StateID> = []
        var pathFromStart: [StateID] = []
        var finished: [StateID] = []
        var cycles: [[StateID]] = []
        var cycleClosingEdges: Set<Edge> = []

        func visit(_ state: StateID) {
            visited.insert(state)
            pathFromStart.append(state)

            for target in (outgoing[state] ?? []).flatMap(\.targets) {
                if let cycleStart = pathFromStart.firstIndex(of: target) {
                    cycles.append(Array(pathFromStart[cycleStart...]))
                    cycleClosingEdges.insert(Edge(from: state, to: target))
                } else if !visited.contains(target) {
                    visit(target)
                }
            }

            pathFromStart.removeLast()
            finished.append(state)
        }

        visit(start)

        self.start = start
        self.reachableInTopologicalOrder = finished.reversed()
        self.reachable = visited
        self.cycles = cycles
        self.transitions = transitions
        self.outgoing = outgoing
        self.cycleClosingEdges = cycleClosingEdges
    }

    func transitions(from state: StateID) -> [WorkflowGraph.Transition] {
        outgoing[state] ?? []
    }

    func transitionsNotClosingCycle(to state: StateID) -> [WorkflowGraph.Transition] {
        transitions.filter { transition in
            transition.targets.contains(state) && !cycleClosingEdges.contains(Edge(from: transition.from, to: state))
        }
    }
}
