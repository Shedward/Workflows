//
//  WorkflowInstanceTable.swift
//  WorkflowEngine
//

import Foundation

/// The instances a storage holds, in last-written order, with the retention rule for finished ones.
struct WorkflowInstanceTable: Sendable {
    static func newInstance(of workflow: AnyWorkflow, initialData: WorkflowData) -> WorkflowInstance {
        WorkflowInstance(
            id: UUID().uuidString,
            workflowId: workflow.id,
            workflowVersion: workflow.version,
            state: workflow.startId,
            transitionState: nil,
            data: initialData
        )
    }

    let retentionInterval: TimeInterval
    private(set) var instances: [WorkflowInstance]

    var running: [WorkflowInstance] {
        instances.filter { $0.finishedAt == nil }
    }

    init(instances: [WorkflowInstance] = [], retentionInterval: TimeInterval) {
        self.instances = instances
        self.retentionInterval = retentionInterval
    }

    func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        instances.first { $0.id == id }
    }

    mutating func put(_ instance: WorkflowInstance) {
        instances = instances.filter { $0.id != instance.id } + [instance]
    }

    mutating func finish(_ instance: WorkflowInstance) -> WorkflowInstance {
        var finished = instance
        finished.finishedAt = Date()
        put(finished)
        return finished
    }

    mutating func removeExpired() -> [WorkflowInstanceID] {
        let now = Date()
        let expired = instances.filter { instance in
            guard let finishedAt = instance.finishedAt else {
                return false
            }
            return now.timeIntervalSince(finishedAt) > retentionInterval
        }
        instances.removeAll { instance in expired.contains { $0.id == instance.id } }
        return expired.map(\.id)
    }
}
