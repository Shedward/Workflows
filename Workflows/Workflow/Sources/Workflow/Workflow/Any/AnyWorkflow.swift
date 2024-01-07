//
//  AnyWorkflow.swift
//
//
//  Created by Vlad Maltsev on 06.12.2023.
//

import LocalStorage
import Combine
import Foundation
import FileSystem

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
    
    public init(
        mockDetails: WorkflowDetails = WorkflowDetails(id: WorkflowId(rawValue: "mock"), type: "Mock Workflow", name: "Mock Workflow Details"),
        state: AnyState = AnyState(id: "mock", name: "Mock State", transitions: [])
    ) {
        self.details = mockDetails
        self.getState = { state }
        self.storage = WorkflowStorage(
            data: InMemoryCodableStorage(),
            rootItem: InMemoryFileSystem().rootItem,
            deleteAllWorkflowData: { }
        )
        self.statePublisher = Empty().eraseToAnyPublisher()
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
