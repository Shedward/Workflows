//
//  InMemoryWorkflowStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Foundation

public actor InMemoryWorkflowStorage: WorkflowStorage {
    private var instances: [WorkflowInstance] = []

    public func create(_ workflow: AnyWorkflow) async throws -> WorkflowInstance {
        let newId = UUID().uuidString
        let instance = WorkflowInstance(id: newId, workflowId: workflow.id, state: workflow.initialState)
        instances.append(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) async throws {
        instances = instances.filter { $0.id != instance.id } + [instance]
    }
    
    public func finish(_ instance: WorkflowInstance) async throws {
        instances = instances.filter { $0.id == instance.id }
    }
    
    public func all() async throws -> [WorkflowInstance] {
        instances
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        instances.first { $0.id == id }
    }
}
