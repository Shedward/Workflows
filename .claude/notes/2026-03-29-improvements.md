# Possible Improvements — 2026-03-29

Collected during full codebase review.

---

## High Priority — Bugs & Safety

### 1. ~~Silent storage errors in WorkflowRunner~~ (RESOLVED)
Replaced all 4 `try?` calls with `do/catch` blocks that log storage errors via `Logger`. Storage failures are no longer silent.

### 2. ~~`fatalError` in property wrappers~~ (WON'T FIX)
Intentional by design. `fatalError` in `@Input`, `@Output`, `@Dependency` is the correct behavior — misuse of these wrappers is a programmer error that should crash loudly. Graph validation catches most cases at startup.

### 3. ~~Manual vs automatic transition failure asymmetry~~ (RESOLVED)
Manual transition failures now persist `transitionState.failed` before throwing, consistent with automatic failures. Client gets both HTTP 500 and queryable failure state. Updated `run_failed_transition` test.

### 4. GithubClient placeholder token
`GithubClient.swift:17` — `StaticTokenAuthorizer("<Token>")`. Known bug #3.

---

## Medium Priority — Documentation & API

### 5. `finishedAt` field undocumented
`WorkflowInstance.finishedAt: Date?` exists in code and integration tests but is missing from `API.md`.

### 6. Timeout query parameter undocumented
`?timeout=N` on POST endpoints is functional (used in `run_slow_workflow`) but not in the API spec. Default is 5s, hardcoded in `WorkflowInstancesController.defaultTimeout`.

### 7. Finished instance retention undocumented
`API.md` says finished instances return 404, but they actually remain queryable for a retention interval (default 3600s) before cleanup.

### 8. ~~`ListBody` encoding unverified~~ (RESOLVED)
`ListBody.swift` encodes via `JSONEncoder().encode(items)` — produces a raw JSON array. Wire format matches API docs.

---

## Medium Priority — Code Quality

### 9. Magic numbers
- `WorkflowRunner.swift:124` — `maxSteps = 1000`
- `InMemoryWorkflowStorage.swift:14` / `JSONFileWorkflowStorage.swift:43` — `retentionInterval = 3600`
- `WorkflowInstancesController` — `defaultTimeout = 5`
- Various token TTLs in GoogleServices auth (3600, 600, 60)

### 10. ~~Force unwraps on URL literals~~ (UNNECESSARY)
All 49 occurrences are on compile-time-known string literals — these can never fail at runtime. Cosmetic noise, not a safety risk.

### 11. ~~`print` instead of Logger~~ (UNNECESSARY)
`SendMessage.swift` is in `TestingWorkflows` — test-only code. Using `print()` in test fixtures is acceptable.

### 12. ~~Silent failures in JSONFileWorkflowStorage~~ (RESOLVED)
Replaced all 3 `try?` calls with `do/catch` blocks that log via `Logger`. Corrupted files, decode failures, and delete errors are now visible in logs.

### 13. ~~Additional `try?` across codebase~~ (UNNECESSARY)
All uses are contextually appropriate: existence checks (keychain), optional error body parsing (OAuth), metadata introspection fallbacks (CollectMetadata, GraphBuilder), and Task.sleep.

---

## Lower Priority — Architecture Gaps

### 14. No retry mechanism for failed transitions

### 15. No timeout for wait transitions
A wait can hang forever with no expiry.

### 16. ~~Subflow data isolation not enforced~~ (RESOLVED)
Implemented this session. Input filtering already existed in `Subflow.swift`. Added output merging: child's declared `@Output` keys are merged back into parent on completion. Integration test `run_subflow_data_flow` covers it.

### 17. No migration path for workflow versions
Bumping a workflow's `version` orphans persisted instances — they throw `WorkflowVersionMismatch` on startup and must be deleted manually.

### 18. ~~`unsatisfiedInput` validation error is dead code~~ (RESOLVED)
Removed this session. The case was never emitted — `.undeclaredWorkflowInput` and `.conditionallyAvailableInput` cover the same scenarios.

### 19. ~~Required inputs not validated at API level~~ (RESOLVED)
Already implemented in `Workflows+Start.swift:32-46` — both `create()` and `start()` call `validateRequiredInputs` which checks `initialData` against `graph.requiredInputs` and throws `MissingRequiredInputs`.

---

## Low Priority — Testing & Hygiene

### 20. Zero unit tests
`Core/Core/Tests/CoreTests/CoreTests.swift` has one placeholder test. All testing is integration-level via shell scripts.

### 21. `Todo` and `Implement` marks overlap
Both define `implement()` with the same name but different semantics: `Implement.swift` is a no-op, `Todo.swift` calls `fatalError`. Confusing overload. Low-priority — consolidate or rename one.
