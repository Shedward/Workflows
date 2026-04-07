@testable import Core
import Testing

@Test func example() {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func withTimeoutCompletesBeforeDeadline() async {
    let result = await withTimeout(seconds: 1.0) { 42 }
    guard case .completed(.success(let value)) = result else {
        Issue.record("expected completed success, got \(result)")
        return
    }
    #expect(value == 42)
}

@Test func withTimeoutCancelsOperationOnTimeout() async {
    actor Flag {
        var observedCancellation = false
        func markCancelled() {
            observedCancellation = true
        }
    }
    let flag = Flag()

    let result = await withTimeout(seconds: 0.05) {
        do {
            try await Task.sleep(for: .seconds(5))
            return 1
        } catch {
            await flag.markCancelled()
            throw error
        }
    }

    guard case .timedOut = result else {
        Issue.record("expected timedOut, got \(result)")
        return
    }

    // Give the cancelled child task a brief moment to record its catch block.
    try? await Task.sleep(for: .milliseconds(200))
    #expect(await flag.observedCancellation)
}
