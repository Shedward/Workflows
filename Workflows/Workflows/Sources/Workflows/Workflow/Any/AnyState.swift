//
//  AnyState.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

public struct AnyState {
    private let getId: () async -> String
    private let getName: () async -> String
    private let getTransitions: () async -> [AnyStateTransition]
    
    init<S: State>(_ wrapped: StateMachine<S>) {
        self.getId = { 
            await wrapped.state.description.id
        }
        
        self.getName = {
            await wrapped.state.description.name
        }
        
        self.getTransitions = {
            await wrapped.transitions.map { $0.asAny() }
        }
    }
    
    public func id() async -> String {
        await getId()
    }
    
    public func name() async -> String {
        await getName()
    }
    
    public func transitions() async -> [AnyStateTransition] {
        await getTransitions()
    }
}

extension StateMachine {
    nonisolated public func asAny() -> AnyState {
        AnyState(self)
    }
}
