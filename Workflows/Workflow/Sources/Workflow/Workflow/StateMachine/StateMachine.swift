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

public actor StateMachine<S: State> {

    nonisolated public let id = UUID()
    nonisolated public let dependencies: S.Dependencies
    public private(set) var state: S
    
    private let storage: ThrowingAccessor<S>
    private let logger = Logger(scope: .workflows)
    
    public init(initialState: S, storage: ThrowingAccessor<S>, dependencies: S.Dependencies) {
        self.state = initialState
        self.storage = storage
        self.dependencies = dependencies
    }
    
    public init(storage: ThrowingAccessor<S>, dependencies: S.Dependencies) async throws {
        self.state = try storage.get()
        self.storage = storage
        self.dependencies = dependencies
    }
    
    public func move(to state: S) async throws {
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
