//
//  AnyWorkflow.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import LocalStorage

public struct AnyWorkflow {
    
    public let details: WorkflowDetails
    public let storage: CodableStorage
    public var state: AnyState {
        getState()
    }
    
    private let getState: () -> AnyState
    
    init<S: State>(_ wrapped: Workflow<S>) {
        self.details = wrapped.details
        self.storage = wrapped.storage
        self.getState = { wrapped.stateMachine.asAny() }
    }
}

extension Workflow {
    public func asAny() -> AnyWorkflow {
        AnyWorkflow(self)
    }
}
