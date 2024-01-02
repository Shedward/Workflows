//
//  Workflow.swift
//
//
//  Created by Vlad Maltsev on 22.10.2023.
//

import Prelude
import LocalStorage
import Dispatch

enum WorkflowKeys {
    static let workflow = "workflow"
    static let state = "state"
}

public final class Workflow<S: State> {
    
    public let details: WorkflowDetails
    public let storage: WorkflowStorage
    let stateMachine: StateMachine<S>
    
    private init(
        details: WorkflowDetails,
        storage: WorkflowStorage,
        stateMachine: StateMachine<S>
    ) {
        self.details = details
        self.storage = storage
        self.stateMachine = stateMachine
    }
    
    public static func load(
        storage: WorkflowStorage,
        dependencies: S.Dependencies
    ) throws -> Workflow<S> {
        let details = try storage.data.load(WorkflowDetails.self, at: WorkflowKeys.workflow)
        let state = try storage.data.load(S.self, at: WorkflowKeys.state)
        
        return Workflow(
            details: details,
            storage: storage,
            stateMachine: StateMachine(
                initialState: state,
                storage: storage.data.accessor(for: WorkflowKeys.state),
                dependencies: dependencies
            )
        )
    }
    
    public static func create(
        details: WorkflowDetails,
        initialState: S, 
        storage: WorkflowStorage,
        dependencies: S.Dependencies
    ) throws -> Workflow<S> {
        let workflow = Workflow(
            details: details,
            storage: storage,
            stateMachine: StateMachine(
                initialState: initialState,
                storage: storage.data.accessor(for: WorkflowKeys.state),
                dependencies: dependencies
            )
        )
        
        try storage.data.save(details, at: WorkflowKeys.workflow)
        try storage.data.save(initialState, at: WorkflowKeys.state)
        
        return workflow
    }
    
    public var state: S {
        stateMachine.state
    }
    
    public var dependencies: S.Dependencies {
        stateMachine.dependencies
    }
    
    public var transitions: [AnyWorkflowTransition] {
        stateMachine.state.description.transitions.map {
            WorkflowTransition(workflow: self, transition: $0.toAny()).asAny()
        }
    }
    
    public func move(to state: S) throws {
        try stateMachine.move(to: state)
    }
    
    public func delete() async throws {
        try await storage.deleteAllWorkflowData()
    }
}
