//
//  StateMachine.swift
//
//
//  Created by Vlad Maltsev on 03.12.2023.
//

import Foundation
import Prelude
import LocalStorage
import os


public final class StateMachine<S: State> {

    public let id = UUID()
    public let dependencies: S.Dependencies
    
    @Published
    public private(set) var state: S
    
    private let storage: ThrowingAccessor<S>
    private let logger = Logger(scope: .workflows)
    
    public init(initialState: S, storage: ThrowingAccessor<S>, dependencies: S.Dependencies) {
        self._state = Published(initialValue: initialState)
        self.storage = storage
        self.dependencies = dependencies
    }
    
    public init(storage: ThrowingAccessor<S>, dependencies: S.Dependencies) throws {
        self.state = try storage.get()
        self.storage = storage
        self.dependencies = dependencies
    }
    
    public func move(to state: S) throws {
        let oldState = self.state
        self.state = state
        try storage.set(state)
        
        logger.info(
            """
            StateMachine(\(self.id)): Moved from \(oldState.description) to \(state.description)
            """
        )
    }
    
    public var transitions: [StateTransition<S>] {
        state.description.transitions.map { transition in
            StateTransition(stateMachine: self, transition: transition)
        }
    }
}
