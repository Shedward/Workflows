//
//  StateTransition.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

public struct StateTransition<S: State>: Identifiable, CustomStringConvertible {
    
    private let stateMachine: StateMachine<S>
    private let transition: AnyTransition<S>
    
    public var id: String {
        transition.id
    }
    
    public var name: String {
        transition.name
    }
    
    public init(stateMachine: StateMachine<S>, transition: AnyTransition<S>) {
        self.stateMachine = stateMachine
        self.transition = transition
    }
    
    public func callAsFunction() async throws {
        try await transition(stateMachine)
    }
    
    public var description: String {
        "StateTransition<\(S.self)>(id: \(id))"
    }
}
