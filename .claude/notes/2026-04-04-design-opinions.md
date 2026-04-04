# Design Opinions: User Input & Branching

## Simplicity Advocate

### Problem 1: User Input — `Prompt` protocol

**Core idea:** Prompt is a thin specialization of Wait. Reuse everything.

- Add `Waiting.userInput(UserInput)` case with prompt string + field descriptors
- New `Prompt` protocol (similar to Wait, ~30 lines)
- `@Input` on Prompt = the fields user must provide (UI reads them via CollectMetadata)
- On first call: collect input metadata, return `.waiting(.userInput(...))`
- On resume: bind submitted data as inputs, run optional `resume()`, complete
- Extend `takeTransition` API to accept optional `data` dict

```swift
@DataBindable
struct ProvideMeetingUrl: Prompt {
    @Input var meetingUrl: URL
    
    var prompt: String { "Please create a meeting and provide the URL" }
    
    func resume() async throws {
        // meetingUrl is now bound from submitted data
    }
}
```

**Changes:** 1 protocol, 1 enum case, ~50 lines. No changes to Transition, graph, or scheduler.

**Note:** Uses `@Input` for the fields user provides (data comes IN from the user). This is semantically different from the flexibility advocate who uses `@Output` (prompt PRODUCES data into the workflow).

### Problem 2: Branching — `BranchingAction` protocol

**Core idea:** Register multiple transitions with the same process from the same state. Add `TransitionResult.branch(StateID)`. New `BranchingAction` protocol where `run()` returns a `State`.

```swift
@DataBindable
struct EvaluateResults: BranchingAction {
    typealias State = MyWorkflow.State
    @Input var testResults: TestResults
    
    func run() async throws -> State {
        testResults.successRate > 0.95 ? .successful : .failed
    }
}

// DSL — just list same process with different targets:
on(.checkResults) {
    EvaluateResults.to(.successful)
    EvaluateResults.to(.failed)
}
```

**Changes:** 1 protocol, 1 enum case on TransitionResult, ~30 lines. Graph already sees two edges.

**Trade-off:** BranchingAction is a separate protocol from Action (different `run()` signature). Simple but means existing Actions can't be easily upgraded to branching.

---

## Flexibility Advocate

### Problem 1: User Input — `Prompt` protocol

**Core idea:** Similar to simplicity advocate but with more structure.

- New `Prompt` protocol with `message` property and `validate()` hook
- Uses `@Output` to declare expected fields (not @Input — prompt PRODUCES data)
- `@Input` for reading existing workflow context into the message
- `Waiting.userInput(UserInput)` with field descriptors including type hints and optionality
- Separate `submitInput` API endpoint (not overloading `takeTransition`)
- On resume: merge submitted data, bind outputs, run `validate()`, complete or reject

```swift
@DataBindable
struct ProvideMeetingUrl: Prompt {
    @Input var meetingTopic: String       // context for the prompt
    @Output var meetingUrl: String        // field the user fills in
    
    var message: String { "Create a meeting for '\(meetingTopic)' and paste the URL" }
    
    func validate() throws {
        guard meetingUrl.hasPrefix("https://") else {
            throw Failure("Must be HTTPS")
        }
    }
}
```

**Key difference from simplicity:** validation hook, @Output for user fields (not @Input), richer field metadata (type, optionality).

### Problem 2: Branching — `Routable` mixin protocol

**Core idea:** Instead of a separate BranchingAction, add a `Routable` mixin that any transition type can conform to. Transition gains `targets: Set<StateID>`.

```swift
public protocol Routable {
    func route() -> StateID?
}
```

- Works with Action, Wait, Prompt, even Pass
- Runner checks `Routable` conformance after `start()` completes
- `route()` returns nil = use default target, or a specific StateID
- Transition struct gets `targets: Set<StateID>` (defaults to `{to}`)
- DSL: `.to(.passed, or: .failed, .needsReview)`

```swift
@DataBindable
struct CheckResults: Action, Routable {
    @Input var testId: String
    @Output var summary: String
    private var significant = false
    
    func run() async throws {
        let result = try await analytics.getTestResult(testId)
        summary = result.summary
        significant = result.isSignificant
    }
    
    func route() -> StateID? {
        significant ? "successful" : "failed"
    }
}
```

**Composition — Prompt + Routable:**

```swift
@DataBindable
struct ApprovalPrompt: Prompt, Routable {
    @Input var description: String
    @Output var approved: Bool
    @Output var reason: String
    
    var message: String { "Review: \(description)" }
    func validate() throws { }
    
    func route() -> StateID? {
        approved ? "approved" : "rejected"
    }
}

on(.pendingApproval) {
    ApprovalPrompt.to(.approved, or: .rejected)
}
```

**Key differences from simplicity:**
1. `Routable` is a mixin — any transition type can branch (Action, Wait, Prompt, Pass)
2. Routing is separate from execution (`route()` vs returning State from `run()`)
3. `Transition` struct gains `targets` set — one logical transition with multiple edges
4. Existing `Action.run()` signature unchanged — backward compatible
5. `Pass & Routable` = pure conditional branch (no code, just routing)

---

## Comparison Matrix

| Aspect | Simplicity | Flexibility |
|--------|-----------|-------------|
| **Prompt: user fields** | `@Input` (data comes in) | `@Output` (prompt produces data) |
| **Prompt: validation** | Optional in `resume()` | Explicit `validate()` hook |
| **Prompt: API** | Extend `takeTransition` | New `submitInput` endpoint |
| **Branching: mechanism** | `BranchingAction` protocol | `Routable` mixin on any type |
| **Branching: Action.run()** | Returns `State` (new signature) | Returns `Void` (unchanged) |
| **Branching: graph model** | Multiple Transitions, same process | Single Transition, `targets` set |
| **Branching: composability** | Only Action can branch | Any transition type can branch |
| **New protocols** | 2 (Prompt, BranchingAction) | 2 (Prompt, Routable) |
| **Backward compat** | BranchingAction is separate | Routable is additive mixin |
