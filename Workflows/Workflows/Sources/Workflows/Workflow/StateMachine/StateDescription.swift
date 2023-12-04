//
//  TransitionsList.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

public struct StateDescription<S: State>: Identifiable, CustomStringConvertible {
    
    public let id: String
    public let name: String
    public let transitions: [AnyTransition<S>]
    
    public init(
        id: String,
        name: String,
        @TransitionsBuilder<S> transitionBuilder: () -> [AnyTransition<S>]
    ) {
        self.id = id
        self.name = name
        transitions = transitionBuilder()
    }
    
    public init(
        id: String,
        name: String
    ) {
        self.id = id
        self.name = name
        transitions = []
    }
    
    public var description: String {
        "StateDescription<\(S.self)>(id: \(id), name: \(name), transitions: \(transitions))"
    }
}
