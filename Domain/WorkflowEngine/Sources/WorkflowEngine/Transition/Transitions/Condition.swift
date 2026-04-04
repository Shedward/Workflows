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
        var condition = self

        try Failure.wrap("Failed to prepare condition \(type(of: self))") {
            try condition.bind(BindInputs(data: context.instance.data))
            try condition.bind(CreateOutputStorage())
            try condition.bind(SetDependencies(container: context.dependancyContainer))
        }

        let runningCondition = condition
        let target = try await Failure.wrap("Failed to run condition \(type(of: self))") {
            try await runningCondition.check()
        }
        condition = runningCondition

        var readOutputs = ReadOutputs(data: context.instance.data)
        try Failure.wrap("Failed to finish condition \(type(of: self))") {
            try condition.bind(&readOutputs)
        }
        context.instance.data = readOutputs.data
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
