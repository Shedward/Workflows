//
//  WorkflowRunner+InstanceLock.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 07.04.2026.
//

import Foundation

struct InflightEntry {
    let id: UUID
    let task: Task<Void, Never>
}

extension WorkflowRunner {
    /// Run `body` after every previously-queued operation for `instanceId`
    /// has completed. Operations on different instances run in parallel.
    /// Callers must use the `*Locked` helpers internally to avoid recursive
    /// re-entry on the same instance, which would deadlock.
    ///
    /// `WorkflowRunner` is an actor, but `takeTransition` has multiple await
    /// points (storage, transition body, scheduler) — actor reentrancy lets
    /// two concurrent calls on the same instance interleave their
    /// load → modify → save sequences and clobber each other. This per-id
    /// task chain closes that hole.
    func withInstanceLock<T: Sendable>(
        _ instanceId: WorkflowInstanceID,
        _ body: @Sendable @escaping () async throws -> T
    ) async throws -> T {
        let previous = inflight[instanceId]?.task
        let work = Task<Result<T, any Error>, Never> {
            await previous?.value
            do {
                return .success(try await body())
            } catch {
                return .failure(error)
            }
        }
        let entryId = UUID()
        let tail = Task<Void, Never> { _ = await work.value }
        inflight[instanceId] = InflightEntry(id: entryId, task: tail)

        let result = await work.value
        if inflight[instanceId]?.id == entryId {
            inflight[instanceId] = nil
        }
        return try result.get()
    }

    func withInstanceLock<T: Sendable>(
        _ instanceId: WorkflowInstanceID,
        _ body: @Sendable @escaping () async -> T
    ) async -> T {
        let previous = inflight[instanceId]?.task
        let work = Task<T, Never> {
            await previous?.value
            return await body()
        }
        let entryId = UUID()
        let tail = Task<Void, Never> { _ = await work.value }
        inflight[instanceId] = InflightEntry(id: entryId, task: tail)

        let result = await work.value
        if inflight[instanceId]?.id == entryId {
            inflight[instanceId] = nil
        }
        return result
    }
}
