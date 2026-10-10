//
//  WorkflowInstanceTable.swift
//  WorkflowEngine
//

import Foundation

/// The instances a storage holds, in last-written order, with the retention rule for finished ones.
struct WorkflowInstanceTable: Sendable {
    let retentionInterval: TimeInterval
    private var instances: [WorkflowInstance] = []

    var running: [WorkflowInstance] {
        instances.filter { $0.finishedAt == nil }
    }

    init(retentionInterval: TimeInterval) {
        self.retentionInterval = retentionInterval
    }

    func instance(id: WorkflowInstanceID) -> WorkflowInstance? {
        instances.first { $0.id == id }
    }

    mutating func put(_ instance: WorkflowInstance) {
        instances.removeAll { $0.id == instance.id }
        instances.append(instance)
    }

    @discardableResult
    mutating func removeExpired() -> [WorkflowInstanceID] {
        let now = Date()
        let expired = instances.filter { instance in
            guard let finishedAt = instance.finishedAt else {
                return false
            }
            return now.timeIntervalSince(finishedAt) > retentionInterval
        }.map(\.id)
        instances.removeAll { expired.contains($0.id) }
        return expired
    }
}
