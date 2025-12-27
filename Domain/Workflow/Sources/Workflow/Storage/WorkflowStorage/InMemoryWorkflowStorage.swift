//
//  InMemoryWorkflowStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Foundation

public final class InMemoryWorkflowStorage: WorkflowStorage {
    private var instances: [WorkflowInstance] = []

    public func create<W>(_ workflow: W) async throws -> WorkflowInstance where W : Workflow {
        let newId = UUID().uuidString
        let instance = WorkflowInstance(id: newId, workflowId: workflow.id)
        instances.append(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) async throws {
        instances = instances.filter { $0.id == instance.id } + [instance]
    }
    
    public func finish(_ instance: WorkflowInstance) async throws {
        instances = instances.filter { $0.id == instance.id }
    }
    
    public func all() async throws -> [WorkflowInstance] {
        instances
    }
}
