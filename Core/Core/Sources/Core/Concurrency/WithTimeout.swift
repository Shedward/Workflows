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
/// If the timeout fires first, returns `.timedOut` and the operation task is
/// cancelled. The operation must respect cancellation (e.g. via
/// `Task.checkCancellation()` or cancellation-aware APIs) for the cancel to
/// actually stop the work — this function only guarantees the cancellation
/// signal is delivered.
public func withTimeout<T: Sendable>(
    seconds: Double,
    operation: @Sendable @escaping () async throws -> T
) async -> TimeoutResult<Result<T, any Error>> {
    await withTaskGroup(of: TimeoutResult<Result<T, any Error>>.self) { group in
        group.addTask {
            do {
                return .completed(.success(try await operation()))
            } catch {
                return .completed(.failure(error))
            }
        }
        group.addTask {
            try? await Task.sleep(for: .seconds(seconds))
            return .timedOut
        }

        let first = await group.next() ?? .timedOut
        group.cancelAll()
        return first
    }
}
