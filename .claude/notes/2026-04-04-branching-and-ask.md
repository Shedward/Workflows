# Conditional Branching & Ask (User Input) — Implementation Notes

## 2026-04-04: Both features implemented and tested

---

## Feature 1: Conditional Branching (Condition)

### What was built

A `Condition` protocol — the 5th transition type — that routes to different states based on runtime logic. All possible targets are declared statically for graph validation.

### Key design decisions

- **Single mechanism, not two.** Early plan had both `Routable` (mixin for any transition) and `Condition` (standalone). Dropped `Routable` in favor of `Condition` only — simpler, and Condition with `@Output` covers the "Action that also branches" case.

- **`targets: [StateID]` replaced `to: StateID`.** Originally kept both (`to` as primary, `targets` as set). Later removed `to` entirely — `targets[0]` is the default/primary target. `TransitionID` no longer includes `to`; identity is `(from, processId, workflow)`.

- **Routing via `WorkflowContext.routedTarget`.** Initially added `TransitionResult.routed(StateID)` case, then merged it away. Condition sets `context.routedTarget = target.id` and returns `.completed`. Runner reads `context.routedTarget ?? transition.targets[0]`. This matches how `@Output` flows back via context mutation.

- **`@DataBindable` macro propagates access level.** Discovered during implementation that the macro was generating internal `bind()` methods for public types. Fixed: macro now detects the containing type's access level and prefixes the generated method accordingly.

### Files added
- `Transition/Transitions/Condition.swift` — protocol + `branching()` DSL helper

### Architecture impact
- `AnyTransition.to` removed, `targets: [StateID]` is the single source of truth
- `TransitionID` simplified to `(from, processId, workflow)`
- `DataFlowAnalyzer.BackEdgeInfo` carries explicit `target: StateID` instead of synthetic transition copy
- `WorkflowGraph.Transition` uses `targets: [StateID]` (no `to`)
- All API models updated: `Transition.targets`, `WorkflowGraph.Transition.targets`, `TransitionID` without `to`

---

## Feature 2: Ask (User Input)

### What was built

An `Asking` protocol — the 6th transition type — that suspends execution and waits for user-provided data via a new REST endpoint.

### Key design decisions

- **Protocol named `Asking`, wrapper named `@Ask`.** Swift doesn't allow a protocol and property wrapper to share the same name. User chose `Asking` for the protocol.

- **`@Ask` is dual-purpose (input + output).** `@Ask` fields are automatically persisted to `WorkflowData` after `process()` runs — no need for separate `@Output` per user field. Eliminates boilerplate. The macro generates a single `ask` binding call; each binding implementation (`CollectMetadata`, `CreateOutputStorage`, `ReadOutputs`, `BindAskInputs`) handles it in its `ask(for:at:)` method. `CollectMetadata` records `@Ask` in both `asks` AND `outputs` sets.

- **Graph validation works without changes.** Since `@Ask` appears in `outputs` (via `CollectMetadata`), downstream transitions see them as available. Since `@Ask` does NOT appear in `inputs`, no false "missing input" errors. The `asks` metadata field is for API exposure only.

- **Separate `POST /answer` endpoint** (not extending `takeTransition`). Semantically distinct: `takeTransition` initiates, `answer` resumes with data. Different validation (checks `asking` state, not available transitions). Returns 409 if instance isn't asking.

- **`typealias Prompt = String`** for the optional prompt message. Kept as a type alias so it can later be replaced with a richer type without breaking existing code.

- **Two-phase `start()` execution:**
  - First call: binds `@Input`, collects `@Ask` metadata, returns `.waiting(.asking(prompt, expectedFields))`
  - Resume (`.answered(data)`): binds `@Input` from WorkflowData, creates output storage for `@Output` and `@Ask`, binds `@Ask` from user data (overwrites empty storage), sets `@Dependency`, calls `process()`, reads all outputs

- **`WaitScheduler` does nothing for `.asking`** — no scheduling needed. The instance just sits until the API call triggers `resumeWaiting` with `.answered(data:)`.

### Files added
- `DataFlow/Interface/AskWrapper.swift` — `@Ask<Value>` property wrapper (readable + writable)
- `DataFlow/Binding/Bindings/BindAskInputs.swift` — populates `@Ask` from user-provided data
- `Transition/Transitions/Ask.swift` — `Asking` protocol, `Prompt` typealias, default `start()`
- `API/WorkflowsInstances/AnswerAsk.swift` — `POST /workflowInstances/:id/answer`
- `TestingWorkflows/AskWorkflow/AskWorkflow.swift` — `AskNameWorkflow` + `AskWithDataWorkflow`
- `Tools/Tests/run_ask` — integration tests

### Files modified
- `DataBinding.swift` — added `ask(for:at:)` with default no-op
- `DataBindableMacro.swift` — recognizes `@Ask`, added `case ask` to `WrapperKind`
- `CollectMetadata.swift` — records `@Ask` in both `asks` and `outputs`; `TransitionMetadata` gained `asks` field
- `CreateOutputStorage.swift`, `ReadOutputs.swift` — handle `@Ask` in `ask(for:at:)`
- `Waiting.swift` — `case asking(Asking)` with `Asking` struct (prompt + expectedFields)
- `WaitScheduler.swift` — `ResumeReason.answered(data:)`, no-op scheduling for `.asking`
- `WorkflowRunner.swift` — `answerAsk(instanceId:data:)` method
- `Workflows+Transitions.swift` — `answer(to:data:)` facade
- `Workflows+Errors.swift` — `InstanceNotAsking` error
- `TransitionState.swift` (API) — `case asking(prompt:, expectedFields:)`, `AskField` struct
- `TransitionState+API.swift` — mapping for `.asking`
- `WorkflowGraph.swift` (API) — `asks` in `TransitionMetadata`
- `WorkflowGraph+API.swift` — mapping for asks
- `WorkflowInstancesController.swift` — `answerAsk` route
- `WorkflowError+HTTPResponseError.swift` — 409 for `InstanceNotAsking`
- `Documentation/API.md` — new endpoint, asking state, behavioral notes

### Remaining work
- **Prompt + Condition composition** — an Ask that also branches based on the answer. Not yet implemented but architecturally possible (Asking + Condition aren't mutually exclusive, would need a combined protocol or a different approach).
- **Validation of submitted fields** — currently no server-side check that the answer contains all expected fields. `BindAskInputs` throws if a field is missing, but the error message could be more user-friendly.
- **`run_failed_transition` pre-existing bug** — unrelated to these features, still failing.
