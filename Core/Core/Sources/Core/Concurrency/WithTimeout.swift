//
//  WithTimeout.swift
//  Core
//
//  Created by Claude on 22.03.2026.
//

import Foundation

public enum TimeoutResult<T: Sendable>: Sendable {
    case completed(T)
    case timedOut
}

/// Races an async operation against a timeout.
///
/// If the operation completes within the deadline, returns `.completed(result)`.
/// If the timeout fires first, returns `.timedOut` — the operation continues
/// running in the background detached from the caller's task tree, and is NOT
/// cancelled. This is intentional: callers (e.g. HTTP handlers) use this to
/// bound how long they wait for a response while letting the underlying work
/// finish on its own.
public func withTimeout<T: Sendable>(
    seconds: Double,
    operation: @Sendable @escaping () async throws -> T
) async -> TimeoutResult<Result<T, any Error>> {
    let state = TimeoutContinuationState<T>()

    Task {
        do {
            let value = try await operation()
            await state.resume(with: .completed(.success(value)))
        } catch {
            await state.resume(with: .completed(.failure(error)))
        }
    }

    Task {
        try? await Task.sleep(for: .seconds(seconds))
        await state.resume(with: .timedOut)
    }

    return await withCheckedContinuation { continuation in
        Task { await state.attach(continuation) }
    }
}

private actor TimeoutContinuationState<T: Sendable> {
    typealias Outcome = TimeoutResult<Result<T, any Error>>

    private var continuation: CheckedContinuation<Outcome, Never>?
    private var pending: Outcome?
    private var resumed = false

    func attach(_ continuation: CheckedContinuation<Outcome, Never>) {
        if let pending {
            self.pending = nil
            resumed = true
            continuation.resume(returning: pending)
            return
        }
        self.continuation = continuation
    }

    func resume(with outcome: Outcome) {
        guard !resumed else {
            return
        }
        if let continuation {
            self.continuation = nil
            resumed = true
            continuation.resume(returning: outcome)
        } else {
            pending = outcome
        }
    }
}
