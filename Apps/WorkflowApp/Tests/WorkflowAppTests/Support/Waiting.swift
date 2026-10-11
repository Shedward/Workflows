import Testing

/// View models start unstructured tasks; this waits until their effect is visible.
@MainActor
func eventually(
    _ expectation: String,
    within timeout: Duration = .seconds(5),
    polling interval: Duration = .milliseconds(10),
    sourceLocation: SourceLocation = #_sourceLocation,
    _ condition: () -> Bool
) async {
    let deadline = ContinuousClock.now + timeout
    repeat {
        if condition() {
            return
        }
        try? await Task.sleep(for: interval)
    } while ContinuousClock.now < deadline
    Issue.record("Never happened: \(expectation)", sourceLocation: sourceLocation)
}

/// Gives already answered requests time to reach the view model, before asserting that nothing changed.
@MainActor
func settle(for duration: Duration = .milliseconds(50)) async {
    try? await Task.sleep(for: duration)
}
