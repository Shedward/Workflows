//
//  Command.swift
//  WorkflowApp
//

import Observation

/// A user action that runs once at a time. `error` keeps the last failure until the next run or `reset`.
@Observable
@MainActor
final class Command {
    private(set) var isRunning = false
    private(set) var error: (any Error)?

    func run(_ work: @escaping @MainActor () async throws -> Void) {
        guard !isRunning else {
            return
        }
        isRunning = true
        error = nil
        Task {
            do {
                try await work()
            } catch {
                self.error = error
            }
            isRunning = false
        }
    }

    func reset() {
        error = nil
    }
}
