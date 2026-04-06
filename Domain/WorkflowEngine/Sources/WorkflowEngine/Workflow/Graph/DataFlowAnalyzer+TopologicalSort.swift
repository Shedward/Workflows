//
//  DataFlowAnalyzer+TopologicalSort.swift
//  WorkflowEngine
//

// MARK: - Topological Sort

extension DataFlowAnalyzer {
    typealias BackEdgeInfo = (transition: WorkflowGraph.Transition, target: StateID, cyclePath: [StateID])

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
                for target in transition.targets {
                    if inStack.contains(target) {
                        let cycleStart = pathStack.firstIndex(of: target) ?? 0
                        let cyclePath = Array(pathStack[cycleStart...])
                        backEdges.append(BackEdgeInfo(transition: transition, target: target, cyclePath: cyclePath))
                    } else if !visited.contains(target) {
                        dfs(target)
                    }
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
