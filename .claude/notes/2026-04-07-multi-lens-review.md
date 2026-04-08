# 2026-04-07 — Multi-lens project review

Four parallel Explore subagents reviewed the project from independent angles: **simplicity**, **architectural cleanliness**, **risks/issues**, and **product stability/changeability**. This note records the raw findings and the consolidated opinion on what to act on.

---

## Lens A — Simplicity

### Over-engineered / candidates to reduce
- **`@Input` / `@Output` / `@Dependency` use `fatalError` on misuse** — `Input.swift:14,18,22`, `Output.swift:19,20`, `Dependency.swift:14,18,22`. Graph validation catches the obvious cases, but lenient mode still allows runtime crashes. Throwing errors or returning optionals would be simpler and safer.
- **DataBinding split across 5 types + a macro** — `DataBinding.swift`, `CollectMetadata.swift`, `BindInputs.swift`, `SetDependencies.swift`, `ReadOutputs.swift`. `Action.swift:18–33` manually chains three bindings; pattern repeats for Wait/Condition/Subflow. Could be inlined or fully codegen'd.
- **Redundant REST body type hierarchy** — 6 files in `Rest/Body`. `JSONBody` declares two parallel protocols (`JSONEncodableBody`, `JSONDecodableBody`) with identical defaults. `ListBody` special-cases an array. `SimpleAction` could just use `JSONEncodable & JSONDecodable`.
- **`DependenciesContainer` uses `DispatchQueue` for thread safety** — `DependenciesContainer.swift:12–34`. The whole system is actor-based; this is anachronistic. Should be an actor or isolated property.
- **`TransitionProcess` premature abstraction** — protocol with `func start()` that all transition types implement identically via extension. `ToTransition`/`FromTransition` builders are thin wrappers (`ToTransition.swift:10–46`). Both instance and static `.to()` exist — unnecessary sugar.
- **`WorkflowContext` stores a `start:` closure** (`WorkflowContext.swift:13`) to avoid a circular dependency on `Workflows`, but couples the runner's signature to the context.
- **Implicit `_start`/`_finish` states** — `Workflow.swift:35–40` derives `startId`/`finishId` from `State.start`/`finish` but they don't appear in the enum definition. Magic.
- **`DataFlowAnalyzer` is sophisticated** — topological sort + three-phase validation. For simple linear workflows, overkill. No way to disable.

### Done well — keep
- `Failure` — structured errors with file/line and context chaining. Minimal, no ceremony.
- `ArrayBuilder` — 45 lines, powers the DSL clearly.
- `Modifiers` protocol — 20 lines, elegant `.with(...)` chain.
- `WorkflowRunner` actor — clean separation: `resume()`, `start()`, `takeTransition()`, `finish()`.
- REST `Api` protocol — 8-line protocol with default associated types; type-safe endpoints without boilerplate.

### Recommendation
Inline DataBinding implementations into Action/Wait/Condition start methods, replace `@Input`/`@Output` `fatalError` with throwing, flatten body types to JSONEncodable/Decodable, and replace `DependenciesContainer`'s `DispatchQueue` with an actor. ~200 lines reduction without losing function.

---

## Lens B — Architectural cleanliness & beauty

### Beautiful
- **Module layering** — Core → Rest, API, WorkflowEngine; Server sits above; API sits between Engine and Server. Textbook horizontal slicing.
- **DSL ergonomics** — `onStart { StartA.to(.stateA) }` reads like English. `@ArrayBuilder<Element>` is minimal yet powerful, used tastefully not fashionably.
- **Disciplined Swift feature usage** — property wrappers carry metadata for the `@DataBindable` macro; the macro is well-scoped (single `bind(_:)` method); actors protect shared state without ceremony.
- **Validation framework** — `DataFlowAnalyzer` does static topological analysis, detects unreachable states, validates data flow, catches missing inputs at startup. `CollectMetadata` introspects without executing; `DataFlowAnalyzer` analyzes; `WorkflowValidator` orchestrates. Pristine separation.

### Ugly
- **Property wrappers abuse `fatalError`** — undermines actor/validation model.
- **Subflow data isolation incomplete** — `filteredData()` warns about stripped keys but doesn't enforce. Phase 2 should enforce strict I/O boundaries.
- **`try?` silently swallows storage errors** in `WorkflowRunner`.
- **Naming nits** — `WorkflowContext` has `dependancyContainer` (typo: dependancy). `TransitionProcess` is too abstract a noun.

### Verdict
Outstanding *vision* — state machine model, validator, DSL design are elegant; layering is clean. Execution has rough edges (fatalErrors, incomplete data isolation, silent error swallowing). Fix those and the architecture is genuinely beautiful.

---

## Lens C — Risks and issues (additional to known list in CLAUDE.md)

### Critical
1. **`WithTimeout` doesn't cancel** — `Core/Concurrency/WithTimeout.swift:26–40`. Comment explicitly states "it is NOT cancelled". On timeout the operation continues in background indefinitely. Resource/memory leak under load.
2. **Unprotected concurrent writes to instances array** — `JSONFileWorkflowStorage.swift:71–78,84`. `instances = instances.filter(...) + [instance]` is not atomic; races with `all()` and `instance(id:)`. State corruption, lost or duplicate instances.
3. **`WaitScheduler` `[weak self]` capture on `WorkflowRunner`** — `WorkflowRunner.swift:18–19`. If timer fires and self deallocates, closure silently drops; if dealloc races with completion, can execute on a deallocated actor.

### High
4. **`runAutomaticTransitions` reachable from 3 callers without per-instance lock** — `Workflows+Start.swift:25–30`, `WorkflowRunner.swift:126,159`. Concurrent `takeTransition` and `resumeWaiting` on the same instance can interleave: load → advance → save → lost update.
5. **Storage failures inside automatic chains are logged but the chain proceeds** — `WorkflowRunner.swift:200–206`. Instance "advances" without persistence; restart loses work.
6. **No infinite-loop detection in automatic chains** — `WorkflowRunner.swift:159–172`. Hardcoded `maxSteps=1000`; bug condition silently hits the limit, instance stuck mid-state.
7. **Race between `storage.finish()` cleanup and child `resumeWaiting`** — child can see nil/stale parent during cleanup window.

### Medium
8. **`WaitScheduler.scheduleTimeWait` cancels old task without `await`-ing** — `WaitScheduler.swift:78–101`. Old + new resume can both fire → double notify.
9. **`WorkflowData` mutation across multi-action chains** — no ordering guarantee on overlapping keys; one write can be lost.
10. **404 vs 410 for finished instances** — `WorkflowInstancesController.swift:35–38`, `InMemoryWorkflowStorage.swift:43–51`. Clients can't distinguish "never existed" from "completed and cleaned".

### Low
11. **Dual failure leaves `.executing`** — `WorkflowRunner.swift:136–145`. Transition fails *and* storage update fails → instance stuck; restart `resume()` doesn't pick it up.
12. **Time-wait resume not idempotent** — `WorkflowRunner.swift:230–261`. Duplicate scheduler fires → double advance.

---

## Lens D — Product stability and changeability

### Helps users
- **Strong startup graph validation** with directive messages (e.g. "Input 'X' required by 'Y' is not produced by any transition", `ValidationResult.swift:42`). Warnings for unreachable states, cycles.
- **Type safety via macros** — `@DataBindable`, `@Input`/`@Output` make data flow explicit and compile-checked.
- **Workflows are plain Swift** — testable in-process, no DSL parsing surprises. Examples in `Workflows/TestingWorkflows/`.
- **Per-call timeout** — `?timeout=N` (default 5s) on state transitions prevents UI hangs.

### Blocks / scares users
- **No version migration** — CLAUDE.md:136. Bumping `workflow.version` orphans persisted instances; `WorkflowVersionMismatch` requires manual deletion. `Workflows+Errors.swift:35–40` defines the error but no handler. `JSONFileWorkflowStorage.swift:66` stores `workflowVersion` but never checks it. **Largest blocker to evolving workflows in production.**
- **Hard `fatalError` in property wrappers** — under `.lenient` validation, any case the static analyzer didn't catch becomes a runtime crash.
- **No retry / backoff / dead-letter / manual recovery API** for failed transitions. Stuck instances need manual intervention. `Task.sleep`-based waits can hang forever.
- **Minimal observability** — ~7–11 Logger calls in WorkflowEngine. No per-instance traces, no transition auditing, no step timing. API shows `{state, transitionState}` but not how it got there.
- **Subflow data isolation weak** — child workflows receive full parent `WorkflowData`. No namespace boundary.
- **Finished instance retention undocumented** — default 3600s soft-delete, but `API.md:77` says "return 404". Discrepancy creates monitoring confusion.

### DSL discoverability
- *Good:* simple, readable, examples present.
- *Poor:* no generated reference, no IDE tooltips, state enum naming conventions implicit, subflow binding requires trial and error.

### Verdict
Safe to **add** new workflows. Risky to **change** existing production workflows. Observability is fine for happy path, tough for production support. Best practice today: treat workflows as immutable, create `v2` rather than mutate.

---

## Consolidated opinion — what to adopt

### Adopt (high signal, multiple lenses agree)
1. **Serialize per-instance mutations in `WorkflowRunner`** — a per-instance lock collapses Risks #2, #4, #5, #7, #8, #12 into one fix. Highest leverage in the report.
2. **Fix `WithTimeout` to actually cancel.**
3. **Replace `fatalError` in property wrappers with thrown errors.** Throwing — not deleting — preserves the validator and DSL while removing the crash risk.
4. **Stop `try?`-swallowing storage errors** in `WorkflowRunner`. Halt the chain on persistence failure.
5. **Define a versioning/migration story.** Even minimally: failed-load instances move to `legacy/`, surfaced via API, never auto-loaded.
6. **`DependenciesContainer` → actor.** Cheap; removes a concurrency-model contradiction.
7. **Enforce subflow I/O** through declared `@Input`/`@Output` (the documented Phase 2).

### Adopt selectively
8. **Per-instance audit log** — `(timestamp, transitionId, state, durationMs, error?)` ring buffer per instance, exposed via API. Production debug story.
9. **Return 410 Gone (or `finished` flag) instead of 404** for completed instances.
10. **Cycle detection in automatic chains** via `(state, dataHash)` seen-set.

### Don't adopt (or defer)
- **Tearing apart the DataBinding split.** Simplicity is right that it's heavy, but the split is exactly what lets `CollectMetadata` introspect without executing — i.e., what makes the validator (the project's strongest asset) possible. Don't dismantle the load-bearing wall to save line count.
- **Flattening the REST body hierarchy.** Cosmetic; zero risk reduction.
- **Making `_start`/`_finish` explicit in every State enum.** The implicit convention is part of why the DSL is pleasant. Document it instead.
- **A "skip validation for trusted workflows" knob.** That's how safety nets get cut down.

### Disagreements between lenses worth noting
- All four lenses dislike the property wrappers, but disagree on the fix. **Throwing > deleting** — preserves the validator integration.
- Simplicity calls the validation framework "overkill"; architecture and stability call it the project's best feature. **Architecture/stability win** — it's what makes the rest of the design safe.

### Suggested priority order if turning into work
1. Per-instance serialization in `WorkflowRunner`.
2. `WithTimeout` cancellation fix.
3. `fatalError` → thrown errors in property wrappers (wire through `Failure`).
4. Remove `try?` on storage writes.
5. Versioning/migration story (design first).
6. `DependenciesContainer` → actor.
7. Per-instance audit log + API exposure.
8. Subflow I/O enforcement (Phase 2).
9. 410 Gone + document retention.
10. Loop detection in `runAutomaticTransitions`.
