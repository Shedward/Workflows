//
//  WaitScheduler.swift
//  Workflow
//
//  Created by Assistant on 02.01.2026.
//

import Foundation
import Core
import os

actor WaitScheduler {
    typealias ResumeHandler = @Sendable (WorkflowInstanceID, ResumeReason) async -> Void

    private var timeTasks: [WorkflowInstanceID: Task<Void, Never>] = [:]
    private var finishWaiters: [WorkflowInstanceID: Set<WorkflowInstanceID>] = [:]
    private let resume: ResumeHandler

    private let logger = Logger(scope: .workflow)

    init(resume: @escaping ResumeHandler) {
        self.resume = resume
    }

    func rebuild(from instances: [WorkflowInstance]) {
        logger?.trace("Rebuilding schedule for instances")
        for instance in instances {
            if case .waiting(let waiting) = instance.transitionState?.state {
                schedule(for: instance.id, waiting: waiting)
            }
        }
    }

    func schedule(for instanceId: WorkflowInstanceID, waiting: Waiting) {
        switch waiting {
        case .time(let time):
            logger?.trace("Schedule waiting for time \(time.date, privacy: .public)")
            scheduleTimeWait(for: instanceId, date: time.date)
        case .workflowFinished(let finished):
            logger?.trace("Schedule waiting for finishing instance \(finished.instanceId, privacy: .public)")
            registerFinishWaiter(waitingId: instanceId, finishedId: finished.instanceId)
        }
    }

    func cancel(for instanceId: WorkflowInstanceID) {
        logger?.trace("Canceled scheduling for \(instanceId)")
        if let task = timeTasks.removeValue(forKey: instanceId) {
            task.cancel()
        }
        // Remove from all finish-waiter sets
        for key in Array(finishWaiters.keys) {
            var set = finishWaiters[key] ?? []
            if set.remove(instanceId) != nil {
                if set.isEmpty {
                    finishWaiters.removeValue(forKey: key)
                } else {
                    finishWaiters[key] = set
                }
            }
        }
    }

    func notifyFinished(_ instanceId: WorkflowInstanceID) async {
        logger?.trace("Notify finishing for \(instanceId)")
        if let waiters = finishWaiters.removeValue(forKey: instanceId) {
            for waiterId in waiters {
                await resume(waiterId, .workflowFinished)
            }
        }

        if let task = timeTasks.removeValue(forKey: instanceId) {
            task.cancel()
        }
    }

    private func scheduleTimeWait(for instanceId: WorkflowInstanceID, date: Date) {
        if let existing = timeTasks.removeValue(forKey: instanceId) {
            existing.cancel()
        }

        let seconds = date.timeIntervalSinceNow
        let nanos: UInt64 = seconds > 0 ? UInt64(seconds * 1_000_000_000) : 0

        logger?.trace("Scheduled \(instanceId) for \(nanos) ns")

        let task = Task { @Sendable in
            if nanos > 0 {
                try? await Task.sleep(nanoseconds: nanos)
            }
            logger?.trace("Schedule \(instanceId) finished")
            guard !Task.isCancelled else { return }
            logger?.trace("Resuming \(instanceId)")
            await resume(instanceId, .time)
        }

        timeTasks[instanceId] = task
    }

    private func registerFinishWaiter(waitingId: WorkflowInstanceID, finishedId: WorkflowInstanceID) {
        var set = finishWaiters[finishedId] ?? []
        set.insert(waitingId)
        finishWaiters[finishedId] = set
    }
}

extension WaitScheduler {
    enum ResumeReason {
        case time
        case workflowFinished
    }
}
