//
//  InMemoryWorkflowStorage.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

import Foundation

public actor InMemoryWorkflowStorage: WorkflowStorage {
    private var instances: [WorkflowInstance] = []
    private let retentionInterval: TimeInterval

    public init(retentionInterval: TimeInterval = 3600) {
        self.retentionInterval = retentionInterval
    }

    public func create(_ workflow: AnyWorkflow, initialData: WorkflowData) async throws -> WorkflowInstance {
        let newId = UUID().uuidString
        let instance = WorkflowInstance(
            id: newId,
            workflowId: workflow.id,
            state: workflow.startId,
            transitionState: nil,
            data: initialData
        )
        instances.append(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) async throws {
        instances = instances.filter { $0.id != instance.id } + [instance]
    }

    public func finish(_ instance: WorkflowInstance) async throws {
        var finished = instance
        finished.finishedAt = Date()
        instances = instances.filter { $0.id != instance.id } + [finished]
        cleanupExpired()
    }

    public func all() async throws -> [WorkflowInstance] {
        cleanupExpired()
        return instances.filter { $0.finishedAt == nil }
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        cleanupExpired()
        return instances.first { $0.id == id }
    }

    private func cleanupExpired() {
        let now = Date()
        instances.removeAll { instance in
            guard let finishedAt = instance.finishedAt else { return false }
            return now.timeIntervalSince(finishedAt) > retentionInterval
        }
    }
}
