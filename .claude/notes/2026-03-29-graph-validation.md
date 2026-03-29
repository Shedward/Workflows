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

- **Integration tests** — Add test workflows that exercise validation (broken data flow, missing inputs, etc.)
- **Graph API endpoint** — Expose `WorkflowGraph` via REST API for UI rendering
- **Subflow output isolation** — Currently subflow outputs write to shared parent `WorkflowData`. Phase 3 would merge only child's declared `@Output` keys back on finish.

---

## 2026-03-29 Session 2: Deeper Graph Validations

### What was done

6 commits on branch `more-detections`:

1. **Eliminated double-analysis** — `WorkflowGraphBuilder` caches `DataFlowAnalyzer.Analysis` alongside the graph. `WorkflowValidator` reads it instead of re-running.

2. **Type mismatch detection** — Data flow propagation now tracks `key → valueType` alongside key sets. When the same key arrives with conflicting types from multiple branches, or a consuming transition's input type differs from what was produced, a `typeMismatch` error is emitted. `WorkflowGraph.requiredInputs`/`producedOutputs` upgraded to `Set<TransitionMetadata.Field>` (key + valueType).

3. **Subflow input validation** — `WorkflowValidator` now checks each subflow transition's `requiredInputs` against parent available data at the source state. Added `subflowId: WorkflowID?` to `WorkflowGraph.Transition` for reliable subflow identity.

4. **Subflow data isolation (warning)** — Subflows now receive only their declared `@Input` keys from parent data. Undeclared keys are logged as warnings. Subflows without any declared `@Input` pass full data unchanged (backward compatible).

5. **Locked automatic loop detection** — When a cycle is detected, checks if any state in the cycle has a manual outgoing transition. All-automatic cycles emit `automaticCycleWithoutExit` error; others remain warnings.

6. **Circular subflow detection** — DFS over subflow dependency graph in `WorkflowRegistry.validateAll`. Circular chains (A→B→A) emit `circularSubflow` error and throw `WorkflowsError.CircularSubflows` in strict mode.

### New errors (5)
- `typeMismatch(key:types:atState:)`
- `unsatisfiedSubflowInput(key:subflowId:atState:)`
- `automaticCycleWithoutExit([StateID])`
- `circularSubflow([WorkflowID])` (registry-level)
- `WorkflowsError.CircularSubflows`

### Key design decisions
- Type checking uses `String(describing:)` strings — catches common cases (String vs Int), may miss generics edge cases (Optional<String> vs String)
- Subflow isolation is warning-only phase: logs but doesn't block. Output isolation (merging child @Output back) is future work.
- Circular subflow error is registry-level, not per-workflow — reported directly in `validateAll`, not via `WorkflowValidationResult`

### Verification
- All 20 integration tests pass (`./Tools/Run/full_check`)
- swiftlint: 0 violations

---

## 2026-03-29 Session 3: Validation Test Workflows & Build Script

### What was done

1. **`./Tools/Run/build` script** — Extracted build logic into a standalone script. `run_server` and `full_check` now delegate to it. Added `-destination "platform=macOS,arch=arm64"` to suppress xcodebuild ambiguous destination warnings.

2. **Validation test workflows** — Created 12 faulty workflows across 5 files in `Workflows/TestingWorkflows/Sources/TestingWorkflows/ValidationTestWorkflows/` to verify all 14 detections fire on startup:
   - `StructuralErrorWorkflows.swift` — `UnreachableFinishWorkflow`, `UnreachableStateWorkflow`
   - `CycleErrorWorkflows.swift` — `AutomaticCycleWorkflow`, `AmbiguousAutomaticWorkflow`
   - `DataFlowErrorWorkflows.swift` — `UndeclaredInputWorkflow`, `UndeclaredOutputWorkflow`, `ConditionalInputWorkflow`, `TypeMismatchWorkflow`, `UnusedInputWorkflow` (+ helper actions)
   - `DependencyErrorWorkflows.swift` — `MissingDependencyWorkflow`
   - `SubflowErrorWorkflows.swift` — `NeedySubflow`, `UnsatisfiedSubflowInputWorkflow`, `CircularAlpha`, `CircularBeta`

3. **`invalidWorkflows` array** — Added `public let invalidWorkflows: [any Workflow]` in `TestingWorkflows.swift`, separate from the valid `workflows` array. Server can opt-in by adding it to the `Workflows` init block.

### Finding: `unsatisfiedInput` is dead code
`ValidationError.unsatisfiedInput` is defined but never emitted. `undeclaredWorkflowInput` covers the same case. Only 10 of 11 error enum cases are reachable.

### Verification
All 14 detections confirmed via `log stream` on server startup:
- 10 errors: `unreachableFinish`, `deadEndState`, `automaticCycleWithoutExit`, `undeclaredWorkflowInput`, `undeclaredWorkflowOutput`, `conditionallyAvailableInput`, `typeMismatch`, `missingDependency`, `unsatisfiedSubflowInput`, `circularSubflow`
- 4 warnings: `unreachableState`, `cycleDetected`, `ambiguousAutomaticTransitions`, `unusedWorkflowInput`

### Remaining work
- Remove dead `unsatisfiedInput` case or find a distinct trigger for it
- Graph API endpoint for UI rendering
- Subflow output isolation (merge child @Output back to parent)
