# 2026-10-04 — Cleanup: project exploration (step 1)

Branch `cleanup`, from `main` at `cbe8425`. Goal of the branch: reduce complexity without changing behavior.
Safety net: `./Tools/Run/full_check` (26 scripts), Core unit tests, SwiftLint (0 violations at start).
This note is the map and the ranked candidate list. Nothing was changed in this step.

## Working rules for this branch

- Behavior-preserving changes only; bugs go to the backlog at the bottom of this note.
- Commit as we go, in medium-sized steps (user, 2026-10-04). Each commit message lists what was removed or
  moved and why, so a single step can be restored with `git show <hash>` / `git revert <hash>`.
- Verify before each batch of commits: `./Tools/Run/build`, `build prod`, `build_app`, `full_check`,
  Core unit tests, SwiftLint.

## Size (non-blank, non-comment Swift lines)

| Module | Files | LOC | Role |
|---|---|---|---|
| Domain/WorkflowEngine | 80 | 2915 | Engine: DSL, runner, storage, data flow, graph validation, macro |
| Apps/WorkflowApp | 37 | 1274 | Menu bar app, FocusHUD |
| Workflows/TestingWorkflows | 33 | 923 | Fixtures for integration tests |
| Core/Rest | 31 | 664 | REST client framework |
| Services/GoogleServices | 13 | 618 | OAuth, Drive, Sheets |
| Apps/WorkflowServer | 15 | 593 | Hummingbird server |
| Core/Core | 22 | 502 | Failure, Logger, builders, Plugins, Keychain |
| Domain/API | 23 | 424 | REST DTOs and endpoint definitions |
| Workflows/HHWorkflows | 23 | 240 | Production workflows |
| Projects | 7 | 213 | Entry points (server, testing server, app) |
| Services/Github, Services/Git | 7 | 181 | |

Only test target: `Core/Core/Tests` (3 tests). Everything else is covered by the shell integration suite.

## Dependency graph

    Core ← Rest ← API ← WorkflowEngine ← WorkflowServer
                    ↑                  ← TestingWorkflows / HHWorkflows (also Git, GoogleServices)
                    └── WorkflowApp (Rest + API only)

## Architectural findings

A1. **Engine depends on the REST DTO layer.** `WorkflowEngine` imports `API` (and through it `Rest`) only in the
    9 files under `WorkflowEngine/API/*+API.swift`. Their only consumers are the two server controllers.
    Moving the mappings into `WorkflowServer` removes the engine → API → Rest dependency completely.
    Needs a public read accessor for `WorkflowData.data` (currently `internal`).
A2. **Facade and runner overlap.** `Workflows` loads instance + workflow, then `WorkflowRunner` reloads the
    instance under the lock and re-validates. Public surface with no callers: `Workflows.run()`,
    `start(_:)` ×2, `takeTransition(id:)`, `transition(id:)`, plus errors only they throw
    (`TransitionNotFound`, `WorkflowInstanceMismatch`).
A3. **`Core` is a grab-bag.** `KeychainStorage` (only GoogleServices), `Metadata` (only Rest), `Plugins`,
    `Marks`. `OAuthProvider` lives in the Rest client framework but is a server/auth concept.
A4. **Unused package:** `Services/Github` has no importer (and the placeholder token from Known Issues).
A5. **Two server entry points** (`workflow-server`, `workflow-server-testing`) duplicate cert/config setup.

## Subsystem hot spots (ranked by complexity × payoff)

S1. **WorkflowRunner** (299 LOC + lock 47). Three copies of "persist failed state, log if that fails"
    (`executeTransitionProcess`, `executeAutomatic`, loop detection); a failing automatic transition is
    persisted twice. "Resolve waiting context" duplicated in `answerAsk` / `resumeWaiting`. Version check
    duplicated. `withInstanceLock` written twice (throwing / non-throwing). `maxSteps` and the seen-set both
    guard loops. `WorkflowContext.start` closure + `dependancyContainer` typo.
S2. **Graph validation** (DataFlowAnalyzer 283, builder 86, validator 83, registry 130). Analyzer threads
    `errors:`/`warnings:` `inout` through 6 static functions (4 `function_parameter_count` suppressions).
    Builder holds two caches and the validator reaches back into it for the analysis. Metadata collection
    exists in three copies. Three hand-written DFS traversals (two in the registry, one in the analyzer).
    Registry mixes storage of workflows with validation orchestration and logging.
S3. **Transition kinds and data binding.** The "bind inputs → create outputs → set dependencies → run →
    read outputs" sequence is copy-pasted in `Action`, `Ask`, `Condition`, `Wait`. Storage unwrapping is
    triplicated in `Input` / `Dependency` / `Ask` (and `Ask` still uses `fatalError`). `ReadOutputs` has two
    identical methods. Macro has four identical switch arms and an unused `Field.type`.
    DSL builders: `chainedAfterStart` and `chainedAfter` are the same function; `chainAfter` naming.
S4. **Server.** `WorkflowError+HTTPResponseError.swift`: 7 errors × 2 identical extensions (108 LOC).
    `WorkflowInstancesController`: the `withTimeout` + 3-arm switch appears 3 times. `AuthController`
    bypasses the Api DSL the other controllers use.
S5. **App Focus view models.** The cancellable-load-task pattern appears 5 times across
    `SwitchViewModel` / `TransitionViewModel`. Mode registry is doubled (enum + descriptor array with a
    `fatalError` lookup + `AnyFocusMode` erasure). `errorRow` duplicated.
S6. **Storage.** `InMemoryWorkflowStorage` and `JSONFileWorkflowStorage` share ~80% (list, retention, create).
S7. **Google auth.** Two token providers duplicate token POST / validation / error decoding, and neither
    uses the project's own Rest framework.

## Dead code (no callers found by grep)

`CleanStorage`, `DataBindable.binded`, `WaitScheduler.cancel`, `WorkflowRegistry.register`, `AnySendableError`,
both `implement()` marks (`Todo.swift` defines `implement` again), `LoggerScope.debug` / `.file`,
`ServiceAccountTokenProvider` + `ServiceAccountCredentials`, `JsonApi`, `PlainTextBody`, `UrlEncodedBody`,
`AddQueryRequestDecorator`, `toStart()`, `chainAfter`, `InputBindingFailed.typeMismatch`, `DataField(api:)`,
`JSONFileWorkflowStorage.decoder`, redundant `TransitionState: Codable` extension (synthesis would do),
the items in A2, and the whole `Github` package.

## Bug backlog — deferred, fix at the END of the cleanup

Decision (user, 2026-10-04): bugs stay out of the cleanup commits. Return to this list when the cleanup is
done and fix them then. Cleanup steps must not change these behaviors, and must not delete the code a fix
needs (`Workflows.run()` / `WorkflowRunner.resume()` / `WaitScheduler.rebuild`, `AddQueryRequestDecorator`).

B1. **`Workflows.run()` is never called**, and never was in git history. So `WorkflowRunner.resume()` never
    runs: after a restart, persisted time waits and subflow waits are not rescheduled, and the
    `WorkflowVersionMismatch` "on startup" described in CLAUDE.md cannot happen. Wiring it in is a behavior
    change (it would throw on stale instances in `~/.workflows/instances`).
B2. `NetworkRestClient.fetch` builds the URL request from the original `request` for query, method and body,
    and from `decoratedRequest` only for path and headers. Decorators cannot change the query. Also
    `String.queryValue` percent-encodes and `URLQueryItem` encodes again. Read from code, not reproduced.
B3. `TransitionViewModel.take`: on cancellation it returns before clearing `runningTransition`.
B4. `Logger.init` default subsystem becomes `me.shedward.workflows.me.shedward.workflows`.
B5. `Ask` property wrapper uses `fatalError`; `Input` / `Dependency` were already moved to explained
    `preconditionFailure`.
B6. `Core/Marks/Todo.swift` declares a second `implement(_:)` (returning `Void`) instead of `todo(_:)`.
    Copy-paste slip; both marks are currently unused.
B7. **Runtime loop protection never fires** (found by all three runner-rewrite agents, confirmed by
    experiment 2026-10-04). `takeTransitionLocked` ends with `runAutomaticTransitionsLocked(from: next)`, and
    that loop calls `takeTransitionLocked` again, so every automatic step opens a nested loop with a fresh
    `seen` set and a fresh step counter. Neither the `(state, transitionId, data)` check nor the 1000-step cap
    ever sees more than one step. Experiment: registered `AutomaticCycleWorkflow` under `.lenient` validation
    in the testing server and started it: no `AutomaticLoopDetected`, 100% CPU, RSS 20 MB → 1.6 GB in 5 s.
    Strict validation rejects purely automatic cycles at startup, but a cycle through a `Condition` that has
    a manual exit passes validation and can still loop at runtime.
    Fix design (2/3 agents converged): one step function that executes a single transition and does NOT run
    the chain; a flat loop that owns the seen-set and the cap; the step reports whether the failure came from
    the process or from the engine (typed error or outcome enum), which also removes the double write of a
    failed automatic step and the retry of a failed step by outer recursion levels. Side effect to decide:
    in the double-fault case one persist attempt is made instead of two.
B8. **`workflowDidStart` is not delivered for instances started over REST** (architecture agent, read from
    code). The plugin callback is only invoked in `WorkflowRunner.start`, which is reached only through
    `WorkflowContext.startSubflow`. The server uses `Workflows.create` + `runAutomaticTransitions(on:)`, which
    never invokes it. So only subflow children report a start.

## Progress log

### Dead-code sweep — done 2026-10-04

Rule used: remove code with no reference in the workspace unless it is documented framework surface or a
deliberate developer tool. 196 lines removed across 18 files, verified as a whole (build test/prod,
build_app, Github + GoogleServices schemes, full_check 26/26, unit tests, SwiftLint 0).

| Commit | What |
|---|---|
| `9916c20` | Unused public engine API: `Workflows.start` ×2, `transition(id:)`, `takeTransition(id:)`, errors `TransitionNotFound` / `WorkflowInstanceMismatch` (+ HTTP mappings, API.md rows), `InputBindingFailed.typeMismatch`, `WorkflowRegistry.register`, `DataField(api:)` |
| `7454f2f` | Engine internals: `CleanStorage`, `binded`, `dependencyKeys` / `askKeys`, `Dependency.projectedValue`, `WaitScheduler.cancel`, `JSONFileWorkflowStorage.decoder`, `chainAfter` |
| `c1aab54` | `AnySendableError`, `JsonApi`, macro's `SwiftLexicalLookup` import + product and `Field.type` |

Left in place, still unreferenced — each is a decision for the user:
- `Services/Github` package: nothing imports it, but it is the canonical endpoint example in
  `Documentation/Architecture.md` and the `gen-api-endpoint` skill.
- `ServiceAccountTokenProvider` + `ServiceAccountCredentials` (156 LOC): superseded by user OAuth, but
  documented in `Documentation/Architecture.md`.
- `ValidationTestWorkflows/*` + `TestingWorkflows.invalidWorkflows` (270 LOC): fixtures for every validation
  error, never registered or asserted. Better turned into real validator tests than deleted.
- `PlainTextBody`, `UrlEncodedBody` (documented body types), `toStart()` (only way to target `_start`),
  `LoggerScope.debug` / `.file`, the `implement()` marks, `ValidationMode.lenient`, `themeBackground`,
  `Repository.assertExists`, small fluent modifiers in Core/Rest.
- Redundant but not dead (left for the subsystem passes): hand-written `TransitionState: Codable`.

### Architecture pass: engine no longer depends on API (A1) — done 2026-10-04

First version `289ead8`: nine `*+API.swift` mapping files moved from `WorkflowEngine/API/` to
`WorkflowServer/API/Mapping/`; `API` dropped from the engine's `Package.swift`; `WorkflowData.data` made
`public internal(set)`.

    Core <- Rest <- API <------------------ WorkflowServer
    Core <- WorkflowEngine <---------------/

Then one `/my:critics-rewrite` round: three agents, isolated worktrees, one axis each, rewriting `289ead8`
over base `1200e17`. Agents did not build; ideas were applied by hand and verified (build test/prod,
full_check 26/26, SwiftLint 0).

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| Keep the move, the Package cut, and `public internal(set) data` exactly as in v1 | yes | yes | yes | kept (3/3) |
| Spell `WorkflowEngine.WorkflowData` in the controller instead of overload resolution between two same-named types | yes | yes | yes | applied (3/3) |
| Fix stale `//  WorkflowEngine` headers in the moved files | noticed | yes | yes (dropped headers) | applied |
| Delete `WorkflowData+API.swift`, inline as `.data.data` at 4 call sites | yes | no | opposite (named accessors) | rejected: contested, `.data.data` reads worse |
| Server-owned wire strings for `TransitionTrigger` (`apiValue` switch) | – | yes | – | rejected for now: new entity around one field (1/3). Recorded below |
| One `instanceResponse` helper for the 3 timeout blocks in `WorkflowInstancesController` | out of scope | yes | out of scope | deferred to the server pass (S4); it is a ready starting point |
| Merge 9 mapping files into 2 direction-named files, rename label `model:` → `engine:` | rejected (breaks rename tracking) | rejected (cosmetic churn) | yes | rejected (1/3, two against) |
| Request-body accessors `engineInitialData` / `engineData` | – | – | yes | rejected: new entity for a one-liner |

Quotes:
- Minimality: "v1 is already close to the floor: eight pure renames plus what the compiler demands."
- Architecture: "v1's placement is right: the server is the only layer that knows both the engine and the
  REST DTOs."
- All three on `WorkflowData.data`: `public internal(set)` is the narrowest that works, because the server
  needs the getter and `Subflow.swift` mutates `parentData.data[key]` inside the engine.

No second round: the first one converged on "nothing more to compress" for this change.

Side findings from the agents (more valuable than the edits):
- REST `trigger` strings are the engine enum's `rawValue` (`TransitionTrigger: String`), used in
  `Transition+API.swift` and `WorkflowGraph+API.swift`. Renaming an engine case would silently change the JSON.
- `WorkflowServer` imports `Core` without declaring it in its `Package.swift` (works transitively).
- Misnomers at the REST boundary that cannot change without changing JSON: `API.Workflow.stateId` holds a
  list; `waitingWorkflow.workflowId` holds an instance id. In `WorkflowInstancesController`, handlers
  `getWorkflows` / `getWorkflow` and locals named `workflowId` actually deal with instances — fix in S4.
- `API.ErrorDescription.init(error:)` is mapping logic living inside the DTO package.
- `WorkflowGraph` DTO arrays (`requiredInputs`, `producedOutputs`, metadata fields) are built by `.map` over a
  `Set`, so their order in the JSON is not stable between runs.
- The `instanceResponse` helper reads the `timeout` query parameter after `workflows.create` instead of
  before; harmless (pure read), but note it when applying in S4.

Scope decision: A2 (facade / runner overlap) is handled at the start of the runner pass (S1), since it changes
runner internals that S1 rewrites anyway.

### Runner pass (S1, with A2) — done 2026-10-04

First version `9dbf83d`, applied round `ad65207`. Runner subsystem (`Runtime/Runner/*` + `Workflows+Transitions`
/ `Workflows+Start`): 643 lines before, 564 after.

**Correction to the exploration.** A2 ("facade and runner overlap") was not accidental duplication. Taking a
transition is a deliberate two-phase protocol: resolve by `processId` against a snapshot BEFORE queueing (an
unavailable transition fails at once instead of waiting behind a running one), then reload under the lock and
require `instance.state == transition.from`. `Tools/Tests/run_concurrent_transitions` depends on it (10
concurrent identical takes → exactly 1 success). The cleanup kept the protocol and moved both phases into the
runner; the facade forwards.

One `/my:critics-rewrite` round over `9dbf83d` (base `b8e0603`):

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| Keep v1 core: one typed-throws lock, two-phase take in the runner, forwarding facade | yes | yes (restructured) | yes | kept |
| One locked function behind `answerAsk` and `resumeWaiting` | yes | yes | no | applied (2/3), with the architecture agent's nil-returning shape |
| `finish` not exposed by the runner | inlined | moved, private | private | applied as `private` |
| `WorkflowContext.start` → `startSubflow` | – | yes | yes | applied (2/3) |
| `Workflows.runAutomaticTransitions(on:)` reuses `instance(id:)` | yes | forwards | yes | applied (2/3) |
| Inline `WaitScheduler.registerFinishWaiter` | yes | – | yes | applied (2/3) |
| `try result.get()` in the lock | yes | – | kept switch | applied (compiles, shorter) |
| Flat loop instead of take ↔ chain mutual recursion | preserved it | yes | yes | NOT applied: behavior change → bug B7 |
| Step reports where it failed (typed error / outcome enum) instead of nested `do/catch` + `nil` | no ("needs a marker type") | yes | yes | deferred with B7 (it comes with un-nesting) |
| Split runner into `InstanceQueue` / `TransitionStep` / `TransitionChain` / `TransitionFailurePolicy` | – | yes | no | rejected: 4 new files, 590 → 720 lines (1/3) |
| `Set<[AnyHashable]>` for the loop signature; loop detection via `error is AutomaticLoopDetected` | yes | no | no | rejected (1/3, weaker typing) |
| One `notFound` error reused in both phases | yes | – | no | rejected: changes `availableTransitions` in the racing case |
| Renames (`inflight`→`queueTails`, `resume`→`resumeReason`, `.time`→`.timeElapsed`, …) | – | some | yes | rejected except `startSubflow` |
| `ResumeReason` top-level instead of `WaitScheduler.ResumeReason` | – | yes | – | not applied (1/3); reasonable, revisit with B7 |

Quotes:
- Minimality: "Keep v1's structure (one typed-throws lock, two-phase take in the runner, forwarding facade) and
  remove every remaining second path."
- Clarity: "The step returns an enum instead of hiding the failure policy in nested `do/catch`, and v1's mutual
  recursion between take and the chain is gone."
- Architecture: "'locked code must not re-lock' is enforced by type boundary instead of the `*Locked` naming."

Side findings (why things are the way they are):
- Why the lock uses two tasks (minimality): "running the body in the caller's task would inherit cancellation,
  and `notifyFinished` cancels the very timer task that drives a resume." Do not "simplify" the lock into
  running the body inline.
- `answerAsk` under the lock does not re-check that the instance is still asking; only the pre-queue check does.
- `Workflows.runAutomaticTransitions(on:)` runs from a snapshot loaded outside the lock.
- `ResumeReason` is nested in `WaitScheduler`, but `.answered` never comes from the scheduler.
- `DataFlow/Storage/WorkflowData.swift` has a comment naming `AutomaticStepSignature` as the reason
  `WorkflowData` is `Hashable`; keep the two in sync.
- The three failure-persist sites differ only in the double-fault case; unifying them is part of B7.
- Bugs B7 and B8 below.

## Proposed order

1. ~~Dead-code sweep~~ — done, see progress log.
2. ~~Architectural pass: A1~~ — done, see progress log. A2 moves into S1.
3. Subsystems: ~~S1 runner~~ (done), then S3 transition kinds and binding, S4 server, S2 graph validation
   (first turn the unused `ValidationTestWorkflows` fixtures into real validator tests), S5 app view models;
   S6 and S7 if still worthwhile.
4. Bug backlog B1–B8, then the pull request.
