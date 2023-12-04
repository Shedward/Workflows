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
    
    private var workflowsById: [WorkflowId: Workflow] = [:]
    
    public let configs: CodableStorage = InMemoryCodableStorage()
    public let sharedCache = WorkflowsCache()
    
    public init(workflows: [Workflow] = []) {
        self.workflowsById = .init(uniqueKeysWithValues: workflows.map { ($0.id, $0) })
    }
    
    public func workflows() async throws -> [Workflow] {
        Array(workflowsById.values)
    }
    
    public func workflow(_ id: WorkflowId) async throws -> Workflow {
        guard let workflow = workflowsById[id] else {
            throw Failure("Workflow with id \(id) not found")
        }
        
        return workflow
    }
    
    public func startWorkflow(name: String) async throws -> Workflow {
        let id = WorkflowId(name: name, suffix: UUID().uuidString)
        let details = WorkflowDetails(id: id, name: name)
        let workflow = Workflow(details: details, storage: InMemoryCodableStorage())
        workflowsById[id] = workflow
        return workflow
    }
    
    public func stopWorkflow(_ id: WorkflowId) async throws {
        workflowsById.removeValue(forKey: id)
    }
}
