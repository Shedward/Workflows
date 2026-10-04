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

public extension Condition {
    static func branching() -> ToTransition<State> {
        assert(!possibleTargets.isEmpty, "Condition \(Self.self) must declare at least one possibleTarget")
        return ToTransition(process: Self(), targets: possibleTargets.map(\.id))
    }

    func start(context: inout WorkflowContext) async throws -> TransitionResult {
        let target = try await runBody(in: &context, failures: failures) {
            try await $0.check()
        }
        context.routedTarget = target.id
        return .completed
    }
}

private extension Condition {
    var failures: BodyFailures {
        BodyFailures(
            prepare: "Failed to prepare condition \(type(of: self))",
            run: "Failed to run condition \(type(of: self))",
            finish: "Failed to finish condition \(type(of: self))"
        )
    }
}
