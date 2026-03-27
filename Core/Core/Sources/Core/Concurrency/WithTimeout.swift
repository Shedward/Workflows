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
/// running in the background (it is NOT cancelled).
public func withTimeout<T: Sendable>(
    seconds: Double,
    operation: @Sendable @escaping () async throws -> T
) async -> TimeoutResult<Result<T, any Error>> {
    let (stream, continuation) = AsyncStream<TimeoutResult<Result<T, any Error>>>.makeStream()

    Task {
        do {
            let value = try await operation()
            continuation.yield(.completed(.success(value)))
        } catch {
            continuation.yield(.completed(.failure(error)))
        }
        continuation.finish()
    }

    Task {
        try? await Task.sleep(for: .seconds(seconds))
        continuation.yield(.timedOut)
        continuation.finish()
    }

    for await result in stream {
        return result
    }

    return .timedOut
}
