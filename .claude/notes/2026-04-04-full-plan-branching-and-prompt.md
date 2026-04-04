# Plan: Conditional Branching & User Input (Prompt)

> **Note:** This was the original plan before implementation. Both features are now complete. The actual implementation diverged significantly — see `2026-04-04-branching-and-ask.md` for what was actually built.

## Context

The workflow engine currently supports linear state transitions — each transition goes to exactly one target state. Two features are needed:

1. **Branching** — a transition that routes to different states based on runtime data (e.g., A/B test result determines success/failure path). The graph must know all possible targets at startup for validation and UI visualization.
2. **Prompt** — a transition that pauses the workflow to collect structured data from a human (e.g., "provide meeting URL"), then resumes with that data flowing into the workflow.

These compose: a Prompt can also branch based on the user's answer (approval flow → approved/rejected).

---

## Architecture: Current State

### Transition data model

A `Transition<State>` (Transition.swift:8) has exactly one `to: StateID`. The `TransitionID` (line 30) includes `from + to + processId + workflow` — making `to` part of the identity.

A `TransitionProcess` (TransitionProcess.swift:8) executes via `start(context:) -> TransitionResult`. `TransitionResult` has two cases: `.completed` and `.waiting(Waiting)`.

The DSL builds `ToTransition<State>` (ToTransition.swift:10) holding `process + to`, which `FromTransition.swift` maps into `Transition` objects.

### How results are handled

In `WorkflowRunner.takeTransition()` (WorkflowRunner.swift:113-119):
- `.completed` → `moveToState(transition.to)` — always uses the single declared target
- `.waiting(let waiting)` → schedules via `WaitScheduler`

### Graph validation

`DataFlowAnalyzer` builds adjacency lists from transitions (DataFlowAnalyzer.swift:94-103):
```swift
outgoing[transition.from].append(transition)
incoming[transition.to].append(transition)
```
Each transition contributes ONE incoming edge to ONE state. Topological sort follows `transition.to` as the neighbor (line 364-371). Data flow propagation computes type maps per state by merging all incoming edge contributions, intersecting keys at merge points (lines 218-227).

### Waiting system

`Waiting` enum (Waiting.swift:10): `.time(Time)` and `.workflowFinished(WorkflowFinished)`.
`WaitScheduler.ResumeReason` (WaitScheduler.swift:109): `.time` and `.workflowFinished(data:)`.
Resume path: `WaitScheduler` calls `WorkflowRunner.resumeWaiting()` which re-executes the transition with the resume reason passed through `WorkflowContext.resume`.

### Transition types

- `Action` (Action.swift:10): `run() async throws`, binds I/O, returns `.completed`
- `Wait` (Wait.swift:10): `resume() -> Waiting.Time?`, returns `.waiting` or `.completed`
- `Pass` (Pass.swift:10): returns `.completed` immediately, no bindings
- Subflow (Subflow.swift:11): starts child workflow, returns `.waiting(.workflowFinished(...))` or `.completed`

Each has a default `start()` implementation via constrained protocol extension (e.g., `Action where Self: TransitionProcess`).

---

## Architecture: Target State

### New `TransitionResult` case

```
TransitionResult
├── .completed          — move to transition.to (existing)
├── .waiting(Waiting)   — suspend (existing)
└── .routed(StateID)    — move to specified target from declared set (NEW)
```

### Transition model gains `targets`

```
Transition<State>
├── id: TransitionID        (unchanged — uses primary `to`)
├── from: StateID           (unchanged)
├── to: StateID             (unchanged — "primary/default" target)
├── targets: Set<StateID>   (NEW — all possible destinations, defaults to {to})
├── process: TransitionProcess
└── trigger: TransitionTrigger
```

### Two branching mechanisms

**Routable** — lightweight mixin for inline routing:
```
protocol Routable { func route() -> StateID? }
```
Any transition type (Action, Wait, Pass, Prompt) can conform. Returns nil = use default `to`, or a StateID to override. Implemented via constrained protocol extensions (e.g., `Action where Self: Routable`).

**Condition** — standalone routing process with full DataBindable support:
```
protocol Condition: TransitionProcess, DataBindable, Sendable, Defaultable {
    associatedtype State: WorkflowState
    static var possibleTargets: [State] { get }
    func check() async throws -> State
}
```
Used as its own `TransitionProcess`. Reads `@Input`/`@Dependency`, returns target state. Reusable across workflows.

### Prompt — new transition type

```
protocol Prompt: TransitionProcess, DataBindable, Sendable, Defaultable {
    var message: String { get }
    func validate() throws
}
```
Uses `@Output` for fields the user must provide, `@Input` for message context, `@Dependency` for validation services.

New waiting case: `Waiting.userInput(UserInput)` with message + field descriptors.
New resume reason: `WaitScheduler.ResumeReason.userInput(data: WorkflowData)`.

Two-phase `start()`: first call returns `.waiting(.userInput(...))`, resume call merges submitted data → validates → returns `.completed`.

### Graph changes

`WorkflowGraph.Transition` gains `targets: Set<StateID>`. `DataFlowAnalyzer.Adjacency` registers each transition as incoming for ALL its targets. Topological sort visits all targets as neighbors. Data flow propagation unchanged in logic — just more edges.

---

## Implementation Plan

### Phase 1: Branching Foundation

**Step 1.1 — TransitionResult.routed**
- File: `Domain/WorkflowEngine/.../Transition/TransitionResult.swift`
- Add case `routed(StateID)`

**Step 1.2 — Transition gains targets**
- File: `Domain/WorkflowEngine/.../Transition/Transition.swift`
  - Add `let targets: Set<StateID>` to `Transition<State>`
  - Existing init: set `targets = [to]` for backward compat
  - New init accepting explicit targets
- File: `Domain/WorkflowEngine/.../Transition/AnyTransition.swift`
  - Add `var targets: Set<StateID> { get }` to protocol

**Step 1.3 — ToTransition gains targets + DSL**
- File: `Domain/WorkflowEngine/.../Transition/Builder/ToTransition.swift`
  - Add `let targets: Set<StateID>` (defaults to `[to]`)
  - Add `.to(_ primary: State, or: State...)` on `TransitionProcess where Self: Defaultable`
- File: `Domain/WorkflowEngine/.../Transition/Builder/FromTransition.swift`
  - Pass `targets` through when creating `Transition` from `ToTransition`

**Step 1.4 — Runner handles .routed**
- File: `Domain/WorkflowEngine/.../Runtime/Runner/WorkflowRunner.swift`
  - In `takeTransition()` result switch (line 113), add:
    ```
    case .routed(let target):
        guard transition.targets.contains(target) else { throw InvalidRouteTarget }
        next = next.transitionEnded().moveToState(target)
    ```
- File: `Domain/WorkflowEngine/.../Workflows/Workflows+Errors.swift`
  - Add `InvalidRouteTarget` error struct

**Step 1.5 — Routable protocol**
- New file: `Domain/WorkflowEngine/.../Transition/Transitions/Routable.swift`
  - Protocol with `func route() -> StateID?`
- File: `Domain/WorkflowEngine/.../Transition/Transitions/Action.swift`
  - Add constrained extension `Action where Self: TransitionProcess, Self: Routable` with `start()` that calls `route()` after `run()`, returns `.routed(target)` or `.completed`
- File: `Domain/WorkflowEngine/.../Transition/Transitions/Wait.swift`
  - Same pattern: after `resume()` returns nil (completed), check `route()`
- File: `Domain/WorkflowEngine/.../Transition/Transitions/Pass.swift`
  - Constrained extension: `Pass & Routable` = pure conditional gateway

**Step 1.6 — Condition protocol**
- New file: `Domain/WorkflowEngine/.../Transition/Transitions/Condition.swift`
  - Protocol with `associatedtype State`, `static var possibleTargets: [State]`, `func check() async throws -> State`
  - Default `start()`: bind inputs → set deps → `check()` → `.routed(target.id)`
  - Static DSL method: `static func branching() -> ToTransition<State>` — constructs ToTransition with `to = possibleTargets[0]`, `targets = Set(possibleTargets.map(\.id))`

### Phase 2: Graph Validation for Branching

**Step 2.1 — WorkflowGraph.Transition targets**
- File: `Domain/WorkflowEngine/.../Workflow/Graph/WorkflowGraph.swift`
  - Add `let targets: Set<StateID>` to `WorkflowGraph.Transition`

**Step 2.2 — GraphBuilder passes targets**
- File: `Domain/WorkflowEngine/.../Workflow/Graph/WorkflowGraphBuilder.swift`
  - In `buildTransitions()` (line 76), include `targets: transition.targets`

**Step 2.3 — DataFlowAnalyzer multi-target support** (most complex step)
- File: `Domain/WorkflowEngine/.../Workflow/Graph/DataFlowAnalyzer.swift`
  - **Adjacency init** (line 94-103): change `incoming[transition.to]` to loop over `transition.targets`:
    ```swift
    for target in transition.targets {
        incoming[target, default: []].append(transition)
    }
    ```
    `outgoing` stays keyed on `from` (unchanged)
  - **Topological sort** (line 364): change `transition.to` neighbor to iterate `transition.targets`
  - **checkStructure** (line 131): exit-check for cycles should check all targets: `!cycleSet.contains($0.to)` → check any target is outside cycle
  - **propagateState** (line 218-224): When computing `edgeTypes` for an incoming edge, the edge carries its outputs regardless of which target reached this state — logic unchanged, just more incoming edges per state
  - **Dead-end check** (line 148): `outgoing[state.id].isEmpty` — still correct since outgoing is keyed on `from`
  - **BackEdgeKey** (line 107): currently uses single `to`. Change to include the target that was visited. Or: since topological sort now visits all targets, the back edge should be per-target. Adjust to `BackEdgeKey(from:to:processId:)` where `to` is the specific target being visited.

### Phase 3: Prompt Feature

**Step 3.1 — Waiting.userInput + ResumeReason**
- File: `Domain/WorkflowEngine/.../Runtime/Waiting/Waiting.swift`
  - Add case `userInput(UserInput)` to `Waiting`
  - Add nested struct `UserInput: Codable, Sendable` with `message: String`, `fields: Set<DataField>`
- File: `Domain/WorkflowEngine/.../Runtime/Runner/WaitScheduler.swift`
  - Add `case userInput(data: WorkflowData)` to `ResumeReason`
  - In `schedule(for:waiting:)` switch (line 34): add `.userInput` case — no scheduling needed (just a no-op, instance waits for API call)
  - In `rebuild(from:)`: handle `.userInput` same as above

**Step 3.2 — Prompt protocol**
- New file: `Domain/WorkflowEngine/.../Transition/Transitions/Prompt.swift`
  - Protocol: `message: String`, `validate() throws`
  - Default `start()` with two paths based on `context.resume`:
    - **First call** (no resume): bind inputs for message context → collect output metadata → return `.waiting(.userInput(message, fields))`
    - **Resume** (`.userInput(data:)`): merge submitted data into `context.instance.data` → bind inputs → create output storage → bind outputs from data → set deps → `validate()` → read outputs → `.completed`
  - Also add `Prompt where Self: Routable` constrained extension (returns `.routed` instead of `.completed` after validation)

**Step 3.3 — BindOutputsFromData** (new binding)
- New file: `Domain/WorkflowEngine/.../DataFlow/Binding/Bindings/BindOutputsFromData.swift`
  - `DataBinding` implementation that reads `@Output` values from `WorkflowData` (reverse of `BindInputs` but for outputs)
  - Used by Prompt resume to populate `@Output` storage from user-submitted data

**Step 3.4 — Facade: submitPrompt**
- File: `Domain/WorkflowEngine/.../Workflows/Workflows+Transitions.swift`
  - Add `func submitPrompt(data: WorkflowData, on instanceId: WorkflowInstanceID) async throws -> WorkflowInstance`
  - Loads instance → verifies `transitionState.state` is `.waiting(.userInput(...))` → finds transition from `transitionState.transitionId` → calls `runner.takeTransition(transition, on: instance, of: workflow, resumeReason: .userInput(data: data))`
- File: `Domain/WorkflowEngine/.../Workflows/Workflows+Errors.swift`
  - Add `InstanceNotWaitingForInput` error

### Phase 4: API Layer

**Step 4.1 — API model updates for branching**
- File: `Domain/API/.../Models/Transition.swift`
  - Add `let targets: [String]` to `API.Transition`
- File: `Domain/API/.../Models/WorkflowGraph.swift`
  - Add `let targets: [String]` to `API.WorkflowGraph.Transition`
- File: `Domain/WorkflowEngine/.../API/Transition+API.swift`
  - Map `model.targets` to API
- File: `Domain/WorkflowEngine/.../API/WorkflowGraph+API.swift` (if exists, else in GraphBuilder API mapping)
  - Map targets

**Step 4.2 — API model updates for Prompt**
- File: `Domain/API/.../Models/TransitionState.swift`
  - Add `case waitingUserInput(message: String, fields: [DataField])` to `TransitionState.State`
- File: `Domain/WorkflowEngine/.../API/TransitionState+API.swift`
  - Map `Waiting.userInput` → `API.TransitionState.State.waitingUserInput`

**Step 4.3 — SubmitPrompt endpoint**
- New file: `Domain/API/.../WorkflowsInstances/SubmitPrompt.swift`
  - `POST /workflowInstances/:id/submitPrompt`
  - Body: `{ data: { "key": "json-encoded-value" } }`
  - Response: `WorkflowInstance`
- File: `Apps/WorkflowServer/.../Controllers/WorkflowInstancesController.swift`
  - Add `submitPrompt` handler: extracts instanceId + data, calls `workflows.submitPrompt(data:on:)`
  - Register route in `endpoints`
- File: `Apps/WorkflowServer/.../Errors/WorkflowError+HTTPResponseError.swift`
  - Add HTTP mapping for `InvalidRouteTarget` (500) and `InstanceNotWaitingForInput` (409 Conflict)

### Phase 5: Testing

**Step 5.1 — Unit tests for branching**
- Add test workflow with Routable Action (simple if/else routing)
- Add test workflow with Condition (standalone routing)
- Test graph validation detects all branch targets
- Test DataFlowAnalyzer correctly handles:
  - Branch where one arm produces key X and another doesn't → conditional availability at merge point
  - Data available on only one branch arm

**Step 5.2 — Unit tests for Prompt**
- Add test Prompt with `@Output` fields
- Test two-phase lifecycle (first call → waiting, resume → completed)
- Test validation failure on resume

**Step 5.3 — Integration tests**
- New test workflows in `Workflows/TestingWorkflows/`
- New test scripts in `Tools/Tests/`:
  - `run_branching` — start workflow, verify it branches correctly
  - `run_prompt` — start workflow, hit submitPrompt endpoint, verify data flows through
  - `run_prompt_branching` — Prompt + Routable composition
- Register in `Tools/Tests/run_all`
- Run `./Tools/Run/full_check`

---

## Key Risks & Mitigations

1. **Swift protocol dispatch** — `Action where Self: Routable` must win over `Action where Self: TransitionProcess` for types conforming to both. Swift picks the more constrained extension. Verify early with a concrete test type.

2. **TransitionID stability** — `TransitionID.to` remains the primary target. Persisted `TransitionState.transitionId` still resolves correctly. No migration needed.

3. **Chain DSL + branching** — `chainedAfterStart` uses `currentStateId = toTransition.to` for sequencing. A branching transition in a chain would only continue from the primary target, which is wrong. **Limitation: branching transitions should not be used inside chains.** Document this; optionally add a build-time warning.

4. **Prompt data injection order** — `BindOutputsFromData` must run AFTER `CreateOutputStorage` sets up the storage containers, and BEFORE `ReadOutputs`. The Prompt's `start()` resume path must sequence: merge data → BindInputs → CreateOutputStorage → BindOutputsFromData → SetDependencies → validate → ReadOutputs.

5. **Routable returning `StateID` (not typed State)** — no associated type on Routable keeps it simple and avoids generic complexity. Safety comes from `transition.targets` runtime validation in the runner.

---

## Files Summary

**New files (5):**
- `.../Transition/Transitions/Routable.swift`
- `.../Transition/Transitions/Condition.swift`
- `.../Transition/Transitions/Prompt.swift`
- `.../DataFlow/Binding/Bindings/BindOutputsFromData.swift`
- `Domain/API/.../WorkflowsInstances/SubmitPrompt.swift`

**Modified files (~18):**
- `.../Transition/TransitionResult.swift` — add `.routed`
- `.../Transition/Transition.swift` — add `targets`
- `.../Transition/AnyTransition.swift` — add `targets`
- `.../Transition/Builder/ToTransition.swift` — add `targets`, new DSL
- `.../Transition/Builder/FromTransition.swift` — pass `targets`
- `.../Transition/Transitions/Action.swift` — Routable extension
- `.../Transition/Transitions/Wait.swift` — Routable extension
- `.../Transition/Transitions/Pass.swift` — Routable extension
- `.../Runtime/Runner/WorkflowRunner.swift` — handle `.routed`
- `.../Runtime/Runner/WaitScheduler.swift` — `.userInput` case
- `.../Runtime/Waiting/Waiting.swift` — `.userInput` case
- `.../Workflow/Graph/WorkflowGraph.swift` — `targets`
- `.../Workflow/Graph/WorkflowGraphBuilder.swift` — pass `targets`
- `.../Workflow/Graph/DataFlowAnalyzer.swift` — multi-target adjacency
- `.../Workflows/Workflows+Transitions.swift` — `submitPrompt`
- `.../Workflows/Workflows+Errors.swift` — new errors
- `Domain/API/.../Models/*` — new fields
- `Apps/WorkflowServer/.../Controllers/WorkflowInstancesController.swift` — new endpoint

## Verification

1. `swift test --package-path Core/Core` — unit tests pass
2. `./Tools/Run/full_check` — build + server + all integration tests
3. Manual: start a branching workflow via API, verify correct routing
4. Manual: start a prompt workflow, call submitPrompt, verify data flows through
