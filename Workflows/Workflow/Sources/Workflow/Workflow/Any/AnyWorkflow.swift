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
    public let storage: WorkflowStorage
    public let statePublisher: AnyPublisher<AnyState, Never>
    
    private let getState: () -> AnyState

    init<S: State>(_ workflow: Workflow<S>) {
        self.details = workflow.details
        self.storage = workflow.storage
        self.getState = { AnyState(state: workflow.stateMachine.state, workflow: workflow) }

        self.statePublisher =
            workflow.stateMachine.$state
                .map { AnyState(state: $0, workflow: workflow) }
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
