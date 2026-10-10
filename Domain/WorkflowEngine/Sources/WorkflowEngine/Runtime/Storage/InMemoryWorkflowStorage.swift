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
        let instance = WorkflowInstanceTable.newInstance(of: workflow, initialData: initialData)
        table.put(instance)
        return instance
    }

    public func update(_ instance: WorkflowInstance) {
        table.put(instance)
    }

    public func finish(_ instance: WorkflowInstance) {
        _ = table.finish(instance)
        _ = table.removeExpired()
    }

    public func all() -> [WorkflowInstance] {
        _ = table.removeExpired()
        return table.running
    }

    public func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        _ = table.removeExpired()
        return table.instance(id: id)
    }
}
