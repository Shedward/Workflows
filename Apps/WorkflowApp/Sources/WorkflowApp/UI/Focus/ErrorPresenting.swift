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
    func run(
        cancelling previous: Task<Void, Never>?,
        _ work: @escaping @MainActor () async throws -> Void
    ) -> Task<Void, Never> {
        previous?.cancel()
        return Task {
            do {
                try await work()
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                self.error = error.localizedDescription
            }
        }
    }
}
