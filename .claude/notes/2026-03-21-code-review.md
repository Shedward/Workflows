# Code Review — 2026-03-21

## Bugs Found

1. **WorkflowInstancesController** — `TakeTransition` route wired to wrong handler (`startWorkflow` instead of `takeTransition`).
2. **WorkflowInstancesController** — `startWorkflow` ignores `initialData` from request body.
3. **GithubClient** — Hardcoded placeholder token (`"<Token>"`).

## Error Handling Concerns

- WorkflowRunner silently swallows storage errors with `try?` in multiple places.
- `@Input`/`@Output` property wrappers use `fatalError` on misuse — could crash the server.

## Missing Test Coverage

Zero Swift unit tests for: WorkflowEngine, REST client, API layer, controllers, Git/Github services. Only bash integration tests exist.

## Missing Features

- No persistent storage (in-memory only, lost on restart).
- No retry mechanism for failed transitions.
- No timeout for waits.
- Workflow `version` field exists but unused by engine.

## Priorities

1. ~~Fix controller bugs (quick wins).~~ DONE
2. Add Swift unit tests for WorkflowEngine core.
3. Replace `fatalError` in Input/Output with proper errors.
4. Add persistent storage implementation.

---

## Session Log

### 2026-03-21

**Fixed bugs 1 & 2:**
- `WorkflowInstancesController`: Renamed second `startWorkflow` overload to `takeTransition` and wired `TakeTransition` route to it.
- `WorkflowInstancesController`: `startWorkflow` now passes `initialData` from request body to the engine.
- `StartWorkflow.RequestBody`: Changed `initialData` type from `String?` to `WorkflowData?` to match engine types.

**Created build & test tooling:**
- `Tools/Run/run_server` — Builds via xcodebuild and runs the server.
- `Tools/Run/full_check` — Builds, starts server, runs all integration tests, then shuts down. Use after every iteration.

**Expanded integration test suite (5 → 13 tests, + 1 skipped):**
- Refactored test DSL into `Tools/Lib/workflow.sh` with helpers: `start_workflow`, `take_transition`, `assert_state`, `assert_exists`, `assert_finished`, `assert_fails`, `assert_data`, `assert_transition_available`, `assert_workflow_registered`, etc.
- New test workflows: `FailingWorkflow` (action that throws), `BranchingWorkflow` (multiple transitions from one state), `InitialDataWorkflow` (reads initial data passed at start).
- New test scripts:
  - `run_error_cases` — nonexistent workflow/instance, invalid/wrong-state transitions
  - `run_data_flow` — verifies Input/Output data propagation between transitions
  - `run_available_transitions` — tests GET transitions endpoint at each state
  - `run_initial_data` — tests passing initialData when starting a workflow
  - `run_multiple_instances` — verifies independent parallel instances
  - `run_workflow_listing` — validates GET /workflows response
  - `run_failing_workflow` — verifies error handling for failing actions
  - `run_branching_workflow` — tests both branches of a fork
- ~~Skipped: `run_automatic_subflow_workflow` — discovered pre-existing bug where automatic subflows get stuck.~~ Now fixed and un-skipped.

**Fixed automatic subflow race condition (2-part fix):**
- **Root cause**: In `Subflow.start()`, `context.start()` runs the child workflow inline including all automatic transitions. If the child is fully automatic, it finishes and `scheduler.notifyFinished()` fires before the parent calls `scheduler.schedule()` — the notification fires with no registered waiters.
- **Part 1** (`Subflow.swift`): After `context.start()` returns, check if child already reached its `finishId`. If so, return `.completed` instead of `.waiting`. This is the real fix — works because `takeAutomaticTransitionsLoop` runs inline on the same actor, so the returned instance already has its final state.
- **Part 2** (`WorkflowRunner.swift`): Added max-steps counter (1000) to `takeAutomaticTransitionsLoop` to prevent infinite loops from cyclic workflow definitions.
- **Rejected**: A `finishedInstances` set in WaitScheduler was considered but removed — it grows unboundedly over the server's lifetime with no cleanup path, and Part 1 already handles the race completely since everything runs on the same actor.

**All 14 integration tests pass (including automatic subflow).**

---

## Future: Event Queue Architecture

Evaluated but deferred — the targeted fix above solves the immediate problem without the complexity. Revisit when the system genuinely needs:
- **Parallel transition execution** — multiple transitions running concurrently
- **External event sources / webhooks** — events arriving from outside the REST API
- **Real-time state observation** — SSE/WebSocket for live workflow state streaming
- **Retry policies / compensation logic** — automatic retry with backoff, saga-style rollbacks

**Key design notes for when we build it:**
- Use a Swift enum for event types (internal, compiler-enforced exhaustive handling)
- Add `EventContext` struct for metadata (trace IDs, retry counts, timestamps)
- Use `AsyncStream` continuations for settlement (supports multiple observers)
- Structure drain loop with single `handle(_:)` method for easy hook points
- Route errors through dedicated `transitionFailed` event (not thrown exceptions)
- Add `Task.yield()` between events for fairness in the cooperative scheduler
- Ensure `processQueue` never throws — catch per-event to avoid poisoning the queue
- Watch out for: `isProcessing` flag pitfalls, settlement continuation leaks, loss of call-stack debuggability
