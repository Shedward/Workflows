import API
import Foundation
import Testing

struct Boom: LocalizedError {
    var errorDescription: String? {
        "boom"
    }
}

extension WorkflowInstance {
    static func stub(_ id: String, state: String = "working", finished: Bool = false) -> WorkflowInstance {
        WorkflowInstance(
            id: id,
            workflowId: "Workflow",
            state: state,
            transitionState: nil,
            data: WorkflowData(),
            finishedAt: finished ? Date() : nil
        )
    }
}

extension API.Transition {
    static func stub(_ processId: String) -> API.Transition {
        API.Transition(processId: processId, fromState: "working", targets: ["next"], trigger: "manual")
    }
}

/// View models start unstructured tasks; this waits until their effect is visible.
@MainActor
func eventually(
    _ expectation: String,
    sourceLocation: SourceLocation = #_sourceLocation,
    _ condition: () -> Bool
) async {
    for _ in 0..<2000 {
        if condition() {
            return
        }
        try? await Task.sleep(for: .milliseconds(1))
    }
    Issue.record("Never happened: \(expectation)", sourceLocation: sourceLocation)
}

/// Gives already answered requests time to reach the view model, before asserting that nothing changed.
@MainActor
func settle() async {
    try? await Task.sleep(for: .milliseconds(50))
}
