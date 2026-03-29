# 2026-03-29: Graph Validation & Introspection (Phase 1)

## What was done

Implemented static graph validation and introspection for the workflow engine. All `@Input`/`@Output`/`@Dependency` data flow is now analyzed at registration time rather than failing at runtime.

### New files (6)

- `WorkflowEngine/DataFlow/Binding/Bindings/CollectMetadata.swift` — `TransitionMetadata` model + `CollectMetadata: DataBinding` introspection binding that records I/O metadata without executing transitions
- `WorkflowEngine/Workflow/Graph/WorkflowGraph.swift` — Graph model with nested `State`/`Transition` types, all `Sendable, Codable, Equatable`
- `WorkflowEngine/Workflow/Graph/ValidationResult.swift` — `ValidationError` (7 cases) and `ValidationWarning` (4 cases) enums, `WorkflowValidationResult` aggregate
- `WorkflowEngine/Workflow/Graph/DataFlowAnalyzer.swift` — Forward data propagation: topological sort via DFS, intersection semantics at merge points, cycle detection via back-edges, conditional input checking
- `WorkflowEngine/Workflow/Graph/WorkflowGraphBuilder.swift` — Builds `WorkflowGraph` from `AnyWorkflow`, caches results, handles subflow metadata collection
- `WorkflowEngine/Workflow/Graph/WorkflowValidator.swift` — Orchestrates dependency check + data flow analysis, returns `WorkflowValidationResult`

### Modified files (7)

- `Workflow.swift` — Protocol now extends `DataBindable, Defaultable`; default empty `bind` method
- `TransitionTrigger.swift` — Added `Sendable, Codable, Equatable` conformances
- `DependenciesContainer.swift` — Added `var keys: Set<String>` computed property
- `WorkflowRegistry.swift` — Graph storage (`[WorkflowID: WorkflowGraph]`), `validateAll(dependencies:mode:)`, `graph(for:)`
- `Workflows.swift` — `ValidationMode` enum, validation call in init, `graph(for:)` public API
- `Workflows+Start.swift` — `validateRequiredInputs` check against graph's `requiredInputs`
- `Workflows+Errors.swift` — `ValidationFailed` and `MissingRequiredInputs` error types

### Design decisions

- **Intersection at merge points**: When multiple paths converge, only data produced by ALL paths is guaranteed available. Inputs available on some paths but not all → error (not warning)
- **Cycles**: Detected via DFS back-edges, reported as warning. Validation uses pre-cycle data only (no fixed-point analysis)
- **Subflows are opaque**: During parent validation, subflow edges use the subflow's declared `@Input`/`@Output` as metadata (not internal transitions)
- **Workflow I/O via `@DataBindable`**: Reuses the same `@Input`/`@Output`/`@DataBindable` macro syntax that Actions use
- **Default validation mode is `.lenient`**: Errors logged but don't block startup

### Verification

- All 13 files pass SwiftLint with 0 violations
- Core unit tests pass (`swift test --package-path Core/Core`)
- Swift compilation succeeds (executable built with validation code confirmed via `strings` check)
- `full_check` has a pre-existing SwiftLint build phase issue with generated test runner files at `Core/Core/.build/*/runner.swift` (line length > 200) — not caused by these changes

## Remaining work

- **Phase 2: Subflow runtime enforcement** (plan Step 8-9) — filter parent `WorkflowData` to child's declared `@Input` keys on subflow start; merge only child's `@Output` keys back on finish. Requires changes to `Subflow.swift`, `WaitScheduler.swift`, `WorkflowRunner.swift`
- **Integration tests** — Add test workflows that exercise validation (broken data flow, missing inputs, etc.)
- **Graph API endpoint** — Expose `WorkflowGraph` via REST API for UI rendering
