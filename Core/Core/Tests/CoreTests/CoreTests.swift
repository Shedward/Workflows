@testable import Core
import Foundation
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

@Test func withTimeoutReturnsTimedOutWithoutCancellingOperation() async {
    actor Flag {
        var operationFinished = false
        func markFinished() {
            operationFinished = true
        }
    }
    let flag = Flag()

    let start = Date()
    let result = await withTimeout(seconds: 0.05) {
        try? await Task.sleep(for: .milliseconds(200))
        await flag.markFinished()
        return 1
    }
    let elapsed = Date().timeIntervalSince(start)

    guard case .timedOut = result else {
        Issue.record("expected timedOut, got \(result)")
        return
    }

    // withTimeout must return promptly — it should not block waiting for
    // the in-flight operation.
    #expect(elapsed < 0.15)

    // The operation continues running in the background even after the timeout.
    try? await Task.sleep(for: .milliseconds(300))
    #expect(await flag.operationFinished)
}
