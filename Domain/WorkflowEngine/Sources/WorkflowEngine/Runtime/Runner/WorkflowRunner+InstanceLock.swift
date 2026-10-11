//
//  WorkflowRunner+InstanceLock.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 07.04.2026.
//

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
    func withInstanceLock<T: Sendable, Thrown: Error>(
        _ instanceId: WorkflowInstanceID,
        _ body: @Sendable @escaping () async throws(Thrown) -> T
    ) async throws(Thrown) -> T {
        let previous = inflight[instanceId]
        let work = Task<Result<T, Thrown>, Never> {
            await previous?.value
            do throws(Thrown) {
                return .success(try await body())
            } catch {
                return .failure(error)
            }
        }
        let tail = Task<Void, Never> { _ = await work.value }
        inflight[instanceId] = tail

        let result = await work.value
        if inflight[instanceId] == tail {
            inflight[instanceId] = nil
        }
        return try result.get()
    }
}
