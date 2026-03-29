# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Workflow is a Swift-based workflow engine that executes state machine-like workflows. It provides a type-safe framework for defining states, transitions (actions, waits, subflows), and data flow between steps, exposed via a REST API server built on Hummingbird.

## Build & Test Commands

```bash
# Build (project uses Xcode workspace, not SPM at the root)
# xcodebuild is the primary build tool — see Tools/Run/run_server for details
swift test --package-path Core/Core            # Unit tests (Core module, Swift Testing)

# Build and run the server
./Tools/Run/run_server

# Build, run server, run all integration tests, then shut down
./Tools/Run/full_check

# Integration tests (require running server on :8080)
./Tools/Tests/run_all                          # Run all integration tests
./Tools/Tests/run_simple_workflow              # Run a single test

# Lint
swiftlint                                      # Run from project root (uses .swiftlint.yml)
swiftlint --fix                                # Auto-fix formatting violations
```

## SwiftLint

- Config: `.swiftlint.yml` at project root. Stricter opt-in rules enabled (see file).
- Xcode integration: Run Script phase calls `Tools/Run/swiftlint` (adds Homebrew to PATH).
- Module override: `Workflows/HHWorkflows/.swiftlint.yml` disables `type_name` and `identifier_name` to allow Cyrillic identifiers.

## Architecture

### Module Structure

- **Core/Core** — Foundation utilities: `Logger` (scoped), `Failure` (structured errors with stack traces), `@ArrayBuilder` (result builder), `Modifiers` (builder pattern), `Defaultable`
- **Core/Rest** — REST client framework: `RestClient` protocol, `NetworkRestClient` (URLSession), type-safe `Request<RequestBody, ResponseBody>`, body types (`JSONBody`, `EmptyBody`, etc.), decorators, validators
- **Domain/WorkflowEngine** — Core engine: workflow protocol, transitions, runner, registry, storage, data flow, wait scheduling
- **Domain/API** — REST API endpoint definitions and shared models (`Workflow`, `WorkflowInstance`, `Transition`, `TransitionState`)
- **Apps/WorkflowServer** — Hummingbird HTTP server with controllers for workflow/instance endpoints
- **Services/Git, Services/Github** — External service integrations
- **Workflows/TestingWorkflows** — Example workflow definitions used by integration tests

### Key Abstractions

**Workflow Protocol** — Define workflows by providing a `State` enum (conforming to `WorkflowState`), an `id`, `version`, and `transitions`. Start/finish states are implicit (`_start`, `_finish`).

**Transition System** — Four types:
- `Action` — Immediate execution with data I/O via `@Input`/`@Output`
- `Pass` — No-op, used for state routing and branching
- `Wait` — Suspends until external signal (time-based or custom condition)
- `Subflow` — Nests another workflow; parent waits for child to finish

**Transition Triggers:**
- `onStart`/`on(.state)` — Manual triggers, require explicit `takeTransition` API call
- `afterStart`/`after(.state)` — Automatic triggers, execute inline without API call

Workflows are defined with a DSL:
```swift
var transitions: Transitions {
    onStart { StartAction.to(.stateA) }       // manual
    on(.stateA) { NextAction.to(.stateB) }    // manual
    on(.stateB) { FinalAction.toFinish() }    // manual
}
// Or automatic:
var transitions: Transitions {
    afterStart {
        StepOne.to(.a)                         // automatic chain
        StepTwo.to(.b)
        StepThree.toFinish()
    }
}
```

**Data Flow** — `@Input<T>` and `@Output<T>` property wrappers for type-safe data binding between transitions. `@DataBindable` macro auto-generates binding conformance. Data stored in `WorkflowData` (JSON-serializable key-value store).

**Runtime** — `Workflows` actor is the main facade. `WorkflowRunner` actor executes transitions and handles automatic transitions. `WorkflowRegistry` maps definitions to instances. `WorkflowStorage` persists state — `InMemoryWorkflowStorage` (default) or `JSONFileWorkflowStorage` (one JSON file per instance in a directory). `WaitScheduler` handles delayed resumption.

`Workflows.init` accepts an optional `storage:` parameter (defaults to `InMemoryWorkflowStorage()`). The server passes `JSONFileWorkflowStorage(directory:)` pointing at `~/.workflows/instances/`.

### Concurrency Model

Actor-based (`Workflows`, `WorkflowRunner`) with Swift async/await throughout. Swift 6.2 concurrency, targeting macOS 26.

### REST API Endpoints

Full specification: `Documentation/API.md`

- `GET /health` — Liveness check
- `GET /workflows` — List workflow types
- `GET /workflowInstances` — List active instances (finished instances are removed)
- `POST /workflowInstances` — Start workflow (`{workflowId, initialData?}`)
- `GET /workflowInstances/:id` — Instance status
- `POST /workflowInstances/:id/takeTransition` — Execute transition (`{transitionProcessId}`)
- `GET /workflowInstances/:id/transitions` — Available transitions from current state

**Key behaviors:**
- Automatic transitions execute inline — the response already reflects the final state.
- Finished instances are deleted from in-memory storage and return 404.
- Subflow transitions create a child instance; parent enters `waitingWorkflow` state.
- All `WorkflowData` values are JSON-encoded strings (`"hello"` → `"\"hello\""`).
- Error responses: `{userDescription, debugDescription}` with appropriate HTTP status codes.

### Testing

When making changes to **WorkflowEngine**, **WorkflowServer**, or **TestingWorkflows**:
1. Add or update integration test scripts in `Tools/Tests/` to cover new or changed behavior.
2. Register new test scripts in `Tools/Tests/run_all`.
3. Run `./Tools/Run/full_check` to build, start the server, and run all integration tests before considering the work done.

**Test infrastructure:**
- `Tools/Lib/request.sh` — HTTP helper (`request METHOD PATH [BODY]`), exits 1 on 4xx/5xx
- `Tools/Lib/workflow.sh` — Test DSL: `start_workflow`, `take_transition`, `assert_state`, `assert_exists`, `assert_finished`, `assert_fails`, `assert_data`, `assert_transition_available`, `assert_transition_unavailable`, `assert_transition_failed`, `assert_workflow_registered`, `start_workflow_with_data`, `instance_count`
- Test workflows defined in `Workflows/TestingWorkflows/` — register new ones in `TestingWorkflows.swift`

### Known Issues

- **Bug #3**: `GithubClient` has a hardcoded placeholder token (`"<Token>"`).
- **Error handling**: `WorkflowRunner` silently swallows storage errors with `try?` in multiple places.
- **`@Input`/`@Output` crash risk**: Property wrappers use `fatalError` on misuse — could crash the server in production.
- **Manual vs automatic failure asymmetry**: Manual transition failures propagate as HTTP 500 but do NOT set `transitionState.failed`. Only automatic transition failures persist the error in `transitionState`. Consider unifying.
- **No migration mechanism** — if a workflow's `version` is bumped, persisted instances with the old version will cause `WorkflowVersionMismatch` on startup; they must be deleted manually.
- **No retry mechanism** for failed transitions.
- **No timeout** for wait transitions.

### Documentation

- `Documentation/API.md` — Full REST API specification (endpoints, models, errors, behaviors)
- `Documentation/Architecture.md` — Code style, REST framework, Api DSL pattern, auth system
- `.claude/notes/` — Session notes with findings, decisions, and plans

### Notes

Project notes are stored in `.claude/notes/`. Use dated markdown files (e.g. `2026-03-21-topic.md`) for session findings, decisions, and plans. Check existing notes at the start of a session for context.

**Session logging:** At the end of each session, append a dated entry to the relevant notes file summarizing what was done — bugs fixed, features added, decisions made, and remaining work. This keeps a running log for future sessions.

### Dependencies

- `hummingbird` (2.0.0+) — HTTP framework
- `swift-configuration` (1.0.0+) — Configuration
- `swift-subprocess` (0.3.0+) — Process execution (Git)
- `swift-syntax` (602.0.0+) — Macro support
