//
//  NewWorkflowDescription.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation

public struct AnyNewWorkflow: Identifiable {
    
    public let id: String
    public let name: String
    
    private let createWorkflowAction: () async throws -> AnyWorkflow
    
    init<S: State>(_ wrapped: NewWorkflow<S>) {
        self.id = wrapped.id
        self.name = wrapped.name
        self.createWorkflowAction = wrapped.createWorkflow
    }
    
    public func createWorkflow() async throws -> AnyWorkflow {
        try await createWorkflowAction()
    }
}

public struct NewWorkflow<S: State>: Identifiable {
    public typealias Dependencies = S.Dependencies
    
    public let initialState: S
    private let storage: WorkflowsStorage<S.Dependencies>
    
    public let id: String
    public let name: String
    
    public init(
        id: String,
        name: String,
        initialState: S,
        storage: WorkflowsStorage<S.Dependencies>
    ) {
        self.id = id
        self.name = name
        self.initialState = initialState
        self.storage = storage
    }
    
    public func createWorkflow() async throws -> AnyWorkflow {
        try await storage.startWorkflow(name: name, initialState: initialState)
    }
    
    public func asAny() -> AnyNewWorkflow {
        AnyNewWorkflow(self)
    }
}
