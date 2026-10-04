//
//  ErrorPresenting.swift
//  WorkflowApp
//

import Foundation

@MainActor
protocol ErrorPresenting: AnyObject {
    var error: String? { get set }
}

extension ErrorPresenting {
    func latest(
        replacing previous: Task<Void, Never>?,
        _ work: @escaping @MainActor () async throws -> Void
    ) -> Task<Void, Never> {
        previous?.cancel()
        return Task {
            do {
                try await work()
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
