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

public struct Workflow<S: State> {
    
    let details: WorkflowDetails
    let storage: CodableStorage
    let stateMachine: StateMachine<S>
    
    private init(details: WorkflowDetails, storage: CodableStorage, stateMachine: StateMachine<S>) {
        self.details = details
        self.storage = storage
        self.stateMachine = stateMachine
    }
    
    public static func load(storage: CodableStorage, dependencies: S.Dependencies) throws -> Self {
        let details = try storage.load(WorkflowDetails.self, at: WorkflowKeys.workflow)
        let state = try storage.load(S.self, at: WorkflowKeys.state)
        
        return Workflow(
            details: details,
            storage: storage,
            stateMachine: StateMachine(
                initialState: state,
                storage: storage.accessor(for: WorkflowKeys.state), 
                dependencies: dependencies
            )
        )
    }
    
    public static func create(details: WorkflowDetails, initialState: S, storage: CodableStorage, dependencies: S.Dependencies) throws -> Self {
        let workflow = Workflow(
            details: details,
            storage: storage,
            stateMachine: StateMachine(
                initialState: initialState,
                storage: storage.accessor(for: WorkflowKeys.state), 
                dependencies: dependencies
            )
        )
        
        try storage.save(details, at: WorkflowKeys.workflow)
        try storage.save(initialState, at: WorkflowKeys.state)
        
        return workflow
    }
}
