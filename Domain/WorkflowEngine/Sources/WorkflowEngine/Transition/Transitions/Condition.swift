//
//  Condition.swift
//  WorkflowEngine
//

import Core

public protocol Condition: TransitionProcess, DataBindable, Sendable, Defaultable {
    associatedtype State: WorkflowState
    static var possibleTargets: [State] { get }
    func check() async throws -> State
}

public extension Condition where Self: TransitionProcess {
    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        let target = try await withBoundData(in: &context, kind: "condition") {
            try await $0.check()
        }
        context.routedTarget = target.id
        return .completed
    }
}

public extension Condition where Self: Defaultable {
    static func branching() -> ToTransition<State> {
        assert(!possibleTargets.isEmpty, "Condition \(Self.self) must declare at least one possibleTarget")
        return ToTransition(process: Self(), targets: possibleTargets.map(\.id))
    }
}
