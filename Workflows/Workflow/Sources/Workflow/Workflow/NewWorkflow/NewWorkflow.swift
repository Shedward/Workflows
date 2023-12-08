//
//  NewWorkflowDescription.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

import Foundation

public protocol AnyNewWorkflow {
    
    var id: String { get }
    var name: String { get }
    
    func createWorkflow() async throws -> AnyWorkflow
}

public struct NewWorkflow<S: State>: AnyNewWorkflow {
    public typealias Dependencies = S.Dependencies
    public let initialState: S
    private let storage: WorkflowsStorage<S.Dependencies>

    public var id: String {
        initialState.description.id
    }

    public var name: String {
        initialState.description.name
    }
    
    public init(initialState: S, storage: WorkflowsStorage<S.Dependencies>) {
        self.initialState = initialState
        self.storage = storage
    }
    
    public func createWorkflow() async throws -> AnyWorkflow {
        try await storage.startWorkflow(name: name, initialState: initialState)
    }
}
