//
//  InMemoryWorkflowsStorage.swift
//  
//
//  Created by Vlad Maltsev on 23.10.2023.
//

import LocalStorage
import Foundation
import Prelude

public actor InMemoryWorkflowsStorage: WorkflowsStorage {
    
    private var workflowsById: [WorkflowId: AnyWorkflow] = [:]
    
    public let configs: CodableStorage = InMemoryCodableStorage()
    public let sharedCache = WorkflowsCache()
    
    public init(workflows: [AnyWorkflow] = []) {
        self.workflowsById = .init(uniqueKeysWithValues: workflows.map { ($0.details.id, $0) })
    }
    
    public func workflows() async throws -> [AnyWorkflow] {
        Array(workflowsById.values)
    }
    
    public func workflow(_ id: WorkflowId) async throws -> AnyWorkflow {
        guard let workflow = workflowsById[id] else {
            throw Failure("Workflow with id \(id) not found")
        }
        
        return workflow
    }
    
    public func startWorkflow<S: State>(name: String, initialState: S) async throws -> AnyWorkflow where S : State {
        let id = WorkflowId(name: name, suffix: UUID().uuidString)
        let details = WorkflowDetails(id: id, type: WorkflowType(S.self), name: name)
        let workflow = try Workflow
            .create(details: details, initialState: initialState, storage: InMemoryCodableStorage())
            .asAny()
        
        workflowsById[id] = workflow
        return workflow
    }
    
    public func stopWorkflow(_ id: WorkflowId) async throws {
        workflowsById.removeValue(forKey: id)
    }
}
