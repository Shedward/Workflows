import Foundation
import Rest
import Synchronization

/// A `RestClient` that answers from queued responses, one queue per route ("GET /path").
/// It ignores task cancellation on purpose, so a test decides when a stale response arrives.
final class FakeServer: RestClient {
    typealias Respond = @Sendable () async throws -> any Sendable

    struct NoResponseQueued: Error {
        let route: String
    }

    struct WrongResponseType: Error {
        let route: String
    }

    private let queuedResponses = Mutex<[String: [Respond]]>([:])
    private let receivedRoutes = Mutex<[String]>([])
    private let answeredCount = Mutex(0)

    var requests: [String] {
        receivedRoutes.withLock { $0 }
    }

    var answered: Int {
        answeredCount.withLock { $0 }
    }

    func on(_ route: String, respond: @escaping Respond) {
        queuedResponses.withLock { $0[route, default: []].append(respond) }
    }

    func fetch<RequestBody, ResponseBody>(
        _ request: Request<RequestBody, ResponseBody>
    ) async throws -> ResponseBody {
        let route = "\(request.method.rawValue) \(request.path ?? "")"
        receivedRoutes.withLock { $0.append(route) }
        defer { answeredCount.withLock { $0 += 1 } }

        let respond = queuedResponses.withLock { queued -> Respond? in
            guard queued[route]?.isEmpty == false else {
                return nil
            }
            return queued[route]?.removeFirst()
        }
        guard let respond else {
            throw NoResponseQueued(route: route)
        }
        guard let response = try await respond() as? ResponseBody else {
            throw WrongResponseType(route: route)
        }
        return response
    }
}

/// Holds a response until the test opens it. Not affected by task cancellation.
final class Gate: Sendable {
    private struct State {
        var isOpen = false
        var waiters: [CheckedContinuation<Void, Never>] = []
    }

    private let state = Mutex(State())

    func wait() async {
        await withCheckedContinuation { continuation in
            let isOpen = state.withLock { state in
                if !state.isOpen {
                    state.waiters.append(continuation)
                }
                return state.isOpen
            }
            if isOpen {
                continuation.resume()
            }
        }
    }

    func open() {
        let waiters = state.withLock { state in
            state.isOpen = true
            defer { state.waiters = [] }
            return state.waiters
        }
        for waiter in waiters {
            waiter.resume()
        }
    }
}
