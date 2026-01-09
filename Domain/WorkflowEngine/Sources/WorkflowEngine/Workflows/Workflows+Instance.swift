//
//  Workflows+Transitions.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

public extension Workflows {
    func instances() async throws -> [WorkflowInstance] {
        try await storage.all()
    }

    func instance(id: WorkflowInstanceID) async throws -> WorkflowInstance {
        guard let instance = try await storage.instance(id: id) else {
            throw WorkflowsError.WorkflowInstanceNotFound(instanceId: id)
        }
        
        return instance
    }
}
