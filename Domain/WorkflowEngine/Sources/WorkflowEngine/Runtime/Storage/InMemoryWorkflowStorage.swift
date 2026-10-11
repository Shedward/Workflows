//
//  InMemoryWorkflowStorage.swift
//  WorkflowEngine
//

import Foundation

public actor InMemoryWorkflowStorage: WorkflowStorage {
    private var table: WorkflowInstanceTable

    public init(retentionInterval: TimeInterval = 3600) {
        table = WorkflowInstanceTable(retentionInterval: retentionInterval)
    }

    public func create(_ workflow: AnyWorkflow, initialData: WorkflowData) -> WorkflowInstance {
        let instance = WorkflowInstance(atStartOf: workflow, data: initialData)
        table.put(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) {
        table.put(instance)
    }

    public func finish(_ instance: WorkflowInstance) {
        table.put(instance.finished(at: Date()))
        table.removeExpired()
    }

    public func all() -> [WorkflowInstance] {
        table.removeExpired()
        return table.running
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        table.removeExpired()
        return table.instance(id: id)
    }
}
