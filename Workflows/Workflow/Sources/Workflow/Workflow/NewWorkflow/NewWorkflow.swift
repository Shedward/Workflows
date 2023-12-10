//
//  NewWorkflowDescription.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation

public struct NewWorkflowDescription: Identifiable {
    public let id: String
    public let key: String?
    public let name: String?
    public let iconName: String
    
    public init(id: String, key: String?, name: String?, iconName: String) {
        self.id = id
        self.key = key
        self.name = name
        self.iconName = iconName
    }
}

public struct AnyNewWorkflow: Identifiable {
    
    public let description: NewWorkflowDescription
    private let createWorkflowAction: () async throws -> AnyWorkflow
    
    public var id: String {
        description.id
    }
    
    init<S: State>(_ wrapped: NewWorkflow<S>) {
        self.description = wrapped.description
        self.createWorkflowAction = wrapped.createWorkflow
    }
    
    public func createWorkflow() async throws -> AnyWorkflow {
        try await createWorkflowAction()
    }
}

public struct NewWorkflow<S: State>: Identifiable {
    public typealias Dependencies = S.Dependencies
    
    public var id: String {
        description.id
    }
    
    public let initialState: S
    private let storage: WorkflowsStorage<S.Dependencies>
    
    public let description: NewWorkflowDescription
    
    public init(
        description: NewWorkflowDescription,
        initialState: S,
        storage: WorkflowsStorage<S.Dependencies>
    ) {
        self.description = description
        self.initialState = initialState
        self.storage = storage
    }
    
    public func createWorkflow() async throws -> AnyWorkflow {
        try await storage.startWorkflow(
            initialState: initialState,
            key: description.key,
            name: description.name
        )
    }
    
    public func asAny() -> AnyNewWorkflow {
        AnyNewWorkflow(self)
    }
}
