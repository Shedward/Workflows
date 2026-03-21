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
- `Tools/Run/run_server_and_test` — Builds, starts server, runs all integration tests, then shuts down. Use after every iteration.

**All 5 integration tests pass.**
