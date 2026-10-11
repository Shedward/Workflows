//
//  Loading.swift
//  WorkflowApp
//

import Observation

/// Data a screen fetches. The last `load` wins, and `.loading` appears only when the request outlives
/// `loadingDelay`, so a quick refresh keeps the previous content on screen.
@Observable
@MainActor
final class Loading<Value> {
    enum State {
        case idle
        case loading
        case loaded(Value)
        case failed(any Error)
    }

    private(set) var state: State

    @ObservationIgnored private let loadingDelay: Duration
    @ObservationIgnored private var task: Task<Void, Never>?

    var value: Value? {
        if case .loaded(let value) = state { value } else { nil }
    }

    var error: (any Error)? {
        if case .failed(let error) = state { error } else { nil }
    }

    var isLoading: Bool {
        if case .loading = state { true } else { false }
    }

    init(_ state: State = .idle, loadingDelay: Duration = .milliseconds(300)) {
        self.state = state
        self.loadingDelay = loadingDelay
    }

    func load(_ work: @escaping @MainActor () async throws -> Value) {
        task?.cancel()
        task = Task { [loadingDelay] in
            let showLoading = Task {
                try? await Task.sleep(for: loadingDelay)
                if !Task.isCancelled {
                    state = .loading
                }
            }
            defer { showLoading.cancel() }
            do {
                let value = try await work()
                guard !Task.isCancelled else {
                    return
                }
                state = .loaded(value)
            } catch {
                guard !Task.isCancelled else {
                    return
                }
                state = .failed(error)
            }
        }
    }

    func reset() {
        task?.cancel()
        state = .idle
    }
}
