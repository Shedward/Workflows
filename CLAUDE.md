# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Workflow is a Swift-based workflow engine that executes state machine-like workflows. It provides a type-safe framework for defining states, transitions (actions, waits, subflows), and data flow between steps, exposed via a REST API server built on Hummingbird.

## Build & Test Commands

```bash
# Build (from any package directory or root)
swift build
swift build -c release

# Run unit tests (Core module has Swift Testing tests)
swift test --package-path Core/Core

# Build and run the server
./Tools/Run/run_server

# Build, run server, run all integration tests, then shut down
./Tools/Run/run_server_and_test

# Integration tests (require running server)
./Tools/Tests/run_all                          # Run all integration tests
./Tools/Tests/run_simple_workflow              # Run a single test
./Tools/Tests/run_waiting_workflow
./Tools/Tests/run_subflow_workflow
./Tools/Tests/run_simple_git_workflow
./Tools/Tests/run_automatic_simple_git_workflow
```

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

**Transition System** — Three types:
- `Action` — Immediate execution with data I/O
- `Wait` — Suspends until external signal
- `Subflow` — Nests another workflow

Workflows are defined with a DSL:
```swift
var transitions: Transitions {
    onStart { StartAction.to(.stateA) }
    on(.stateA) { NextAction.to(.stateB) }
    on(.stateB) { FinalAction.toFinish() }
}
```

**Data Flow** — `@Input<T>` and `@Output<T>` property wrappers for type-safe data binding between transitions. `@DataBindable` macro auto-generates binding conformance. Data stored in `WorkflowData` (JSON-serializable key-value store).

**Runtime** — `Workflows` actor is the main facade. `WorkflowRunner` actor executes transitions and handles automatic transitions. `WorkflowRegistry` maps definitions to instances. `WorkflowStorage` persists state (in-memory default). `WaitScheduler` handles delayed resumption.

### Concurrency Model

Actor-based (`Workflows`, `WorkflowRunner`) with Swift async/await throughout. Swift 6.2 concurrency, targeting macOS 26.

### REST API Endpoints

- `GET /workflows` — List workflow types
- `GET /workflowInstances` — List instances
- `POST /workflowInstances` — Start workflow
- `GET /workflowInstances/:id` — Instance status
- `POST /workflowInstances/:id/takeTransition` — Execute transition
- `GET /workflowInstances/:id/transitions` — Available transitions

### Notes

Project notes are stored in `.claude/notes/`. Use dated markdown files (e.g. `2026-03-21-topic.md`) for session findings, decisions, and plans. Check existing notes at the start of a session for context.

**Session logging:** At the end of each session, append a dated entry to the relevant notes file summarizing what was done — bugs fixed, features added, decisions made, and remaining work. This keeps a running log for future sessions.

### Dependencies

- `hummingbird` (2.0.0+) — HTTP framework
- `swift-configuration` (1.0.0+) — Configuration
- `swift-subprocess` (0.3.0+) — Process execution (Git)
- `swift-syntax` (602.0.0+) — Macro support
