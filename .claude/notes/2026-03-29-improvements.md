# Possible Improvements — 2026-03-29

Collected during full codebase review.

---

## High Priority — Bugs & Safety

### 1. Silent storage errors in WorkflowRunner
`WorkflowRunner.swift` lines 90, 163, 174, 186 use `try?` to silently discard storage failures. If persistence fails, the server continues with stale state and nobody knows.

### 2. `fatalError` in property wrappers
8 `fatalError`s across `Input.swift`, `Output.swift`, `Dependency.swift`. Server defaults to `.lenient` validation, so graph checks don't fully prevent runtime crashes.

### 3. Manual vs automatic transition failure asymmetry
Manual transition failures return HTTP 500 but don't persist `transitionState.failed`. Automatic failures do. Inconsistent for API clients trying to observe failure state.

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

### 8. `ListBody` encoding unverified
`API.md` says "raw JSON array" but implementation uses `ListBody<T>` wrapper. Should confirm they produce the same wire format.

---

## Medium Priority — Code Quality

### 9. Magic numbers
- `WorkflowRunner.swift:124` — `maxSteps = 1000`
- `InMemoryWorkflowStorage.swift:14` / `JSONFileWorkflowStorage.swift:43` — `retentionInterval = 3600`
- `WorkflowInstancesController` — `defaultTimeout = 5`
- Various token TTLs in GoogleServices auth (3600, 600, 60)

### 10. Force unwraps on URL literals
49 `!` across 17 files, mostly `URL(string: "https://...")!`. Safe for compile-time-known literals but noisy. Consider a helper or static lets.

### 11. `print` instead of Logger
`TestingWorkflows/WaitingWorkflow/Actions/SendMessage.swift:16` uses `print("Message \(messageFile) sent")` instead of the project's `Logger`.

### 12. Silent failures in JSONFileWorkflowStorage
`JSONFileWorkflowStorage.swift` lines 19, 22, 96 — `try?` when reading/decoding/deleting instance files. A corrupted file silently vanishes.

### 13. Additional `try?` across codebase
- `UserOAuthTokenProvider.swift` lines 87, 128, 133, 245
- `ServiceAccountTokenProvider.swift:124`
- `KeychainStorage.swift:53`
- `CollectMetadata.swift:72`
- `WorkflowGraphBuilder.swift:104`
- `WaitScheduler.swift:88`, `WithTimeout.swift:37` (Task.sleep — acceptable)

---

## Lower Priority — Architecture Gaps

### 14. No retry mechanism for failed transitions

### 15. No timeout for wait transitions
A wait can hang forever with no expiry.

### 16. Subflow data isolation not enforced
Subflows receive full parent `WorkflowData`; nothing scoped by declared `@Input`/`@Output`. Planned as Phase 2 of graph validation.

### 17. No migration path for workflow versions
Bumping a workflow's `version` orphans persisted instances — they throw `WorkflowVersionMismatch` on startup and must be deleted manually.

### 18. `unsatisfiedInput` validation error is dead code
Defined in `ValidationResult` but never emitted by `DataFlowAnalyzer`. Noted in graph-validation session notes.

### 19. Required inputs not validated at API level
`Workflows.create()` doesn't check provided `initialData` against the workflow's declared `@Input` from the graph. Validation only happens at transition execution time (via `fatalError`).

---

## Low Priority — Testing & Hygiene

### 20. Zero unit tests
`Core/Core/Tests/CoreTests/CoreTests.swift` has one placeholder test. All testing is integration-level via shell scripts.

### 21. `Todo` and `Implement` marks overlap
Both `Core/Marks/Todo.swift` and `Core/Marks/Implement.swift` serve the same purpose (deprecated compile-time markers). Could consolidate.
