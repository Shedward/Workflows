//
//  AnyWorkflow.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import LocalStorage

public struct AnyWorkflow: Identifiable {
    
    public var id: WorkflowId {
        details.id
    }
    
    public let details: WorkflowDetails
    public let storage: CodableStorage
    
    private let getState: () async -> AnyState
    
    init<S: State>(_ wrapped: Workflow<S>) {
        self.details = wrapped.details
        self.storage = wrapped.storage
        self.getState = {
            let state = await wrapped.stateMachine.state
            let transitions = await wrapped.stateMachine.transitions
            return AnyState(
                id: state.description.id,
                name: state.description.name,
                transitions: transitions.map { $0.asAny() }
            )
        }
    }
    
    public func state() async -> AnyState {
        await getState()
    }
}

extension Workflow {
    public func asAny() -> AnyWorkflow {
        AnyWorkflow(self)
    }
}
