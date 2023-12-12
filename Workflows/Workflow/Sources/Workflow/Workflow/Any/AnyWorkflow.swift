//
//  AnyWorkflow.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import LocalStorage
import Combine
import Foundation

public struct AnyWorkflow: Identifiable {

    public var id: WorkflowId {
        details.id
    }

    public let details: WorkflowDetails
    public let storage: CodableStorage
    public let statePublisher: AnyPublisher<AnyState, Never>
    
    private let getState: () -> AnyState

    init<S: State>(_ wrapped: Workflow<S>) {
        self.details = wrapped.details
        self.storage = wrapped.storage
        self.getState = {
            let state = wrapped.stateMachine.state
            let transitions = wrapped.stateMachine.transitions
            return AnyState(
                id: state.description.id,
                name: state.description.name,
                transitions: transitions.map { $0.asAny() }
            )
        }

        let stateMachine = wrapped.stateMachine
        self.statePublisher =
            wrapped.stateMachine.$state
                .map { state in
                    AnyState(
                        id: state.description.id,
                        name: state.description.name,
                        transitions: state.description.transitions.map { transition in
                            StateTransition(stateMachine: stateMachine, transition: transition)
                                .asAny()
                        }
                    )
                }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }

    public func state() -> AnyState {
        getState()
    }
}

extension Workflow {
    public func asAny() -> AnyWorkflow {
        AnyWorkflow(self)
    }
}
