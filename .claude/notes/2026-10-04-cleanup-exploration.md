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

### Status after the bugfix phase (2026-10-10)

| Bug | Status | Commit |
|---|---|---|
| B2 | fixed, with the new `RestTests` target | `e723836` |
| B3, B30, B31, B32, B33 | fixed, five app tests | `ae6ce87` |
| B4 | fixed | `8bae674` |
| B5 | fixed | `4f3ab60` |
| B7, B9, B15 | fixed during the cleanup | `4d7f906`, `8aa9809`, `49cda0a` |
| B10 | fixed, no test (race window too narrow for the shell suite) | `ed4da3f` |
| B11 | fixed | `8ee9a54` |
| B12 | fixed | `9652d8c` |
| B13 | fixed, unit test | `49d07a2` |
| B14 | fixed | `c76aeda` |
| B17, B18 | fixed, integration test | `0e4eac9` |
| B19 | fixed for the duplication; the environment-variable override of host/port still bypasses the redirect URI | `c22b537` |
| B20 | fixed, every `WorkflowsError` is `DescriptiveError` | `11bf633` |
| B22 | fixed, integration test with a Cyrillic id | `80f0697` |
| B23, B24, B25, B27, B28 | fixed, three new validator tests | `f37a354` |
| B34, B35 | fixed, two storage tests | `9b293e0` |
| B21 | closed without change: `instance(id:)` only throws after eviction, and retention (3600 s) is longer than the longest timeout (600 s) | – |
| B6 | waits for the decision on the developer marks (both are unused) | – |
| B36 | left as is (minor) | – |
| B1 | fixed (user, 2026-10-10: option 1, skip and log; migrations come later), three restart tests | see commit "Resume persisted instances on startup" |
| B8, B16, B26, B29 | NEED A DECISION, see below | – |

Decisions needed:
- ~~**B1**~~ Done: `App.main` calls `workflows.run()` before serving; unregistered or other-version instances
  are skipped with a warning and kept. Dry run over a copy of the real directory (144 files: 92 finished
  evicted, 52 orphans of testing workflows skipped and still listed as running) started fine. The warning
  lines could not be captured through `log show` in the sandbox; the skip behavior is covered by unit tests.
- **B8** Deliver `workflowDidStart` for instances started over REST (today only subflow children get it).
  Plugin semantics; decide whether listeners expect it.
- **B16** Answer client mistakes (malformed JSON, missing body, `MissingRequiredInputs`) with 400 and an
  `ErrorResponse` instead of a bare 500. API contract change; one line per error in the table plus the
  body-decoding errors in `API+Route`.
- **B26** The duplicate-id check in `WorkflowRegistry.init` cannot fire. Make it real (compare before
  deduplication) or drop `throws` from the initializer (touches `Workflows.swift` and the tests).
- **B29** Validation ignores a `DataBindable` process that is not `Defaultable`, while the runtime binds it.
  Decide whether `Defaultable` is required for every process (then enforce at the type level) or drop it
  from the metadata cast.

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
B7. ~~Runtime loop protection never fires~~ — **FIXED 2026-10-04 in `4d7f906`** (pulled forward by the user
    because of the evidence). Cause: `takeTransitionLocked` ended with `runAutomaticTransitionsLocked`, whose
    loop called `takeTransitionLocked` again, so every automatic step got a fresh `seen` set and step
    counter. Experiment before the fix: `AutomaticCycleWorkflow` under `.lenient` validation ran undetected
    at 100% CPU, RSS 20 MB → 1.6 GB in 5 s. A cycle with a manual exit passes strict validation too.
    Fix: `executeTransitionLocked` runs one transition and never the chain; the chain is one flat loop.
    Regression test: `Tools/Tests/run_automatic_loop` with `AutomaticLoopWorkflow` (red before, green after).
    Not done, still optional: let the step report whether the process or the engine failed (2/3 agents), which
    would remove the double write of a failed automatic step. The minimality agent argued against it.
B8. **`workflowDidStart` is not delivered for instances started over REST** (architecture agent, read from
    code). The plugin callback is only invoked in `WorkflowRunner.start`, which is reached only through
    `WorkflowContext.startSubflow`. The server uses `Workflows.create` + `runAutomaticTransitions(on:)`, which
    never invokes it. So only subflow children report a start.
B9. ~~The automatic step cap stops a chain silently~~ — **FIXED 2026-10-04** (user: mark it failed now).
    Before, hitting `maxSteps` only logged and returned the instance with `transitionState: null`, so over
    REST it looked healthy while an automatic transition stayed pending forever. Now the instance is marked
    failed with `WorkflowsError.AutomaticStepLimitReached(instanceId, state, transitionId, limit)`.
    A chain may use all 100 steps and end on its own; it only fails when another automatic step is still
    pending. Cap lowered from 1000 to 100 the same day (`8aa9809`; user: 100 is the maximum reasonable chain).
    Both chain errors (`AutomaticLoopDetected`, `AutomaticStepLimitReached`) are `DescriptiveError` now, so
    the stored `userDescription` is readable instead of "The operation couldn't be completed".
    Test: `test_step_cap_stops_changing_loop` in `Tools/Tests/run_automatic_loop` (`CountingLoopWorkflow`).
B10. **A late answer can resume the wrong transition** (architecture agent, read from code; also noted in the
    runner pass). `WorkflowRunner.answerAsk` checks "is asking" on a snapshot, but `resumeTransition` under the
    lock resumes whatever transition is recorded then. If a first answer completed the ask and the instance
    moved on to a time `Wait` or a subflow, a second concurrent answer would re-run that `Wait` early, or
    re-enter `Subflow.start` with `.answered` and start a second child. Fix: re-check `.asking` under the lock.
B11. **REST arrays built from sets have unstable order** (3/3 agents). `Waiting.Asking.expectedFields` comes from
    `Set<DataField>`; so do `requiredInputs` / `producedOutputs` / metadata arrays in the workflow graph DTO.
    Their order differs between server runs. Fix: sort by key where the set is turned into an array.
B12. **Chain builders assert `targets.count <= 1` and then read `targets[0]`** (3/3 agents). An empty target
    list passes the assert and crashes; with asserts compiled out a branching step silently chains from its
    first target. Low: only `Condition.branching()` builds multi-target steps, and it asserts non-empty.
B13. **An optional `@Output` / `@Ask` set to `nil` fails** as "Value is not provided in output K" (2/3 agents, read
    from code): `ValueStorage` holds `Sendable?`, so the optional is flattened.
B14. **`ValueStorage` takes `&lock` on a stored `os_unfair_lock_s`** (minimality agent). Swift does not guarantee
    a stable address for that pattern. Fix: `OSAllocatedUnfairLock`.
B15. ~~`?timeout=nan` (or `inf`, or a huge value) kills the server~~ — **FIXED 2026-10-04** (user: fix the
    crash). Cause: `WorkflowInstancesController.timeout(from:)` accepted anything `Double()` parses and
    `withTimeout` passed it to `Task.sleep(for: .seconds(...))`, which traps: "Double value cannot be converted
    to _Int128 because it is outside the representable range". One `POST /workflowInstances?timeout=nan` and
    the process was gone. Fix: a value that is not finite means the default (5 s); finite values are kept
    within `0...600`. Negative still means "answer at once", as before.
    Test: `Tools/Tests/run_http_edge_cases` sends nan, inf, -inf, 1e30, -1, abc and then checks `/health`
    (red before: server dead on the first value). `Core.withTimeout` itself still traps on such input; it is
    only called from this controller.
B16. **Client mistakes answer with a bare 500 and an empty body**: malformed JSON, a missing body, and
    `MissingRequiredInputs` on start. They should be 400 with an `ErrorResponse`. With the new table
    (`ErrorResponse.init?(mappedFrom:)`) each is a one-line addition, plus body-decoding errors in `API+Route`.
B17. **Success responses carry no `Content-Type` header** (error responses do). `ApiResponse` ignores
    `DataEncodable.contentType`.
B18. **Two different 404 shapes for an unknown workflow**: `GET /workflows/:id/graph` throws a Hummingbird
    `HTTPError` (`{"error":{"message":...}}`), every other endpoint answers `ErrorResponse`.
B19. **The production entry point hardcodes the OAuth redirect URI** `https://127.0.0.1:8443/auth/google/callback`,
    repeating `Config`'s default host and port and `AuthController`'s route. Environment variables are read
    before the in-memory `Config` values, so overriding host or port leaves the redirect URI stale.
B20. **Two error-to-text mappings disagree**: over HTTP an engine error gets a fixed text from the table; the same
    error stored in `transitionState.failed` gets `localizedDescription` ("The operation couldn't be
    completed..."), via `API.ErrorDescription(error:)` / `TransitionState+Codable`.
B21. On timeout the fallback `workflows.instance(id:)` can throw `WorkflowInstanceNotFound` if the instance was
    already removed, turning a slow success into a 404 (clarity agent, read from code, low).
B22. **Path parameters are not percent-decoded** (confirmed by experiment, 2026-10-05, production server in a
    sandboxed home). `GET /workflows/<percent-encoded Cyrillic id>/graph` and `/starting` answer 404 with the raw
    `%D0…` id in the message; `GET /workflows/SimpleWorkflow/graph` works on the testing server. Every production
    workflow id is Cyrillic, so both endpoints are unusable in production. Unnoticed because the app uses the
    flat `/startingWorkflows` list and instance ids are UUIDs. Fix: decode in the one place path parameters are
    read (`API+Route`), plus an integration case with a non-ASCII id.

B23–B29 come from the graph validation round (2026-10-05). They were read from code by the rewrite agents; unless
a test is named, they are NOT verified by experiment. The cleanup kept every one of these behaviors.

B23. **Transitions from unreachable states take part in merging** (all three agents). Such an edge carries no
    data, so "one unreachable transition into a state wipes out all data there, including declared inputs"
    (clarity). Result: false `conditionallyAvailableInput` / `undeclaredWorkflowInput` errors caused by dead code,
    and "a *declared* input lost at the merge produces no error downstream" (minimality).
    Fix: `GraphTopology.transitionsNotClosingCycle(to:)` should also skip sources that are not reachable.
B24. **Messages that describe a different check than the one performed** (all three agents):
    - `unreachableState` says "never used in any transition"; the check is "not reachable from start" and also
      fires for a state that has outgoing transitions.
    - `undeclaredWorkflowInput` says "not produced by any transition" even when one branch produces it. One cause
      then gets two errors (test `inputProducedOnOnlyOneBranch` expects both).
    - `unsatisfiedSubflowInput` always comes together with `undeclaredWorkflowInput` for the same subflow
      transition, because both read the same declared inputs (test `subflowInputParentDoesNotProvide` expects
      both). So "subflows first" and the shared builder only matter for that duplicate.
    - `automaticCycleWithoutExit` says "only automatic transitions"; the check is only "no manual transition
      leaves the cycle", so an all-manual closed loop or a cycle with an automatic exit gets it too (clarity).
    - The consumer `typeMismatch` names neither the consuming process nor which type is produced and which is
      expected (clarity).
B25. **A declared `@Output` type is never compared with the produced type**; `producedOutputs` carries the type
    that arrives at finish (all three agents).
B26. **The duplicate-id check in `WorkflowRegistry.init` can never fire** (all three agents): discovery already
    keeps one workflow per id, so two workflow types with one id are silently merged and the `throw Failure` is
    dead. Not removed in the cleanup: without it the initializer no longer throws, which changes the public
    signature (`try` at `Workflows.swift` and six test call sites) and trips `unneeded_throws_rethrows`.
    Decide: make the check real (compare before deduplication) or drop `throws`.
B27. **A type conflict is remembered only at the merge state** (clarity, minimality). One state later the key
    silently has the alphabetically first type, so a later consumer gets a misleading second mismatch or none.
B28. In a subflow cycle, the workflow validated first has its subflow's inputs unchecked, silently: the subflow's
    graph is not built yet (clarity, minimality; low).
B29. Validation ignores a `DataBindable` process that is not `Defaultable`, while the runtime binds it
    (architecture). Minimality adds that the `Defaultable` requirement in `collectMetadata()` is a leftover:
    "nothing calls `init()` any more". Also: `ValidationError.circularSubflow` is only ever logged, never part of
    a `WorkflowValidationResult`.

B30–B33 come from the app view models round (2026-10-05). Read from code, NOT verified by experiment. The
cleanup kept every one of these behaviors.

B30. **A cancelled request is not a `CancellationError` with the real client** (all three agents, and my own
    reading). `NetworkRestClient.fetch` wraps `session.data` errors in `Failure.wrap("Executing request")`, so a
    cancelled in-flight request reaches the view model as a `Failure`. `catch is CancellationError` then only
    catches the view model's own cancellation check. "In production a replaced in-flight request probably sets
    `error`; 'cancelled is silent' holds only with `FakeServer`" (clarity). Expected symptom: an error row flashes
    when a refresh replaces a running one (for example `.task(id:)` plus the refresh after a take).
    Fix: one place, `ErrorPresenting.latest` (ignore any failure of a cancelled task), or rethrow cancellation
    unwrapped in the client.
B31. **`take` has a race and a stuck marker** (all three agents). `runningTransition` is set inside the task, so
    two `take` calls in one main-actor turn both pass the guard and the second cancels the first. A take that
    ends in its cancellation branch leaves `runningTransition` set for good. "`take` mixes two policies: the
    guard says 'ignore while running', the slot says 'latest wins'" (architecture).
    Fix (minimality's version): set `runningTransition` synchronously before the task; then the guard is enough
    and `takeTask` with its cancellation branches can go.
B32. **`TransitionViewModel.refresh` without an active workflow** clears `transitions` but neither cancels an
    in-flight refresh nor clears `error`, so a stale response can refill the list (all three agents).
B33. **Switch mode error handling** (minimality, clarity): `showActiveWorkflows` does not clear `error` and
    `SwitchView` hides everything behind it, so after a failed start "<Back>" leaves the error on screen. A
    successful `start` does not clear `error` and sets `state` without animation. A replaced `start` silently
    drops an instance the server already created.

B34–B36 come from the storage round (2026-10-10). Read from code, NOT verified by experiment; pre-existing.

B34. **After a restart `all()` is in directory-listing order**, not last-written order: the file storage loads
    `contentsOfDirectory` in whatever order it comes (clarity, architecture). Noticeable in the app's running
    list after a server restart.
B35. **Memory and disk can diverge in the file storage**: `create`, `update` and `finish` put the instance into
    the table before `save`; if the write throws, the table has it and the file does not (clarity,
    architecture). The runner then sees a state the next restart will not.
B36. Small ones (minimality): `finish` or `update` of an unknown id silently adds it; `finish` of an already
    finished instance overwrites `finishedAt`; with a retention of 0 or less `finish` writes a file and deletes
    it at once. Tests use retention `-1` for "evict at once"; `0` would be flaky (clarity).

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

### Transition kinds and data binding (S3) — done 2026-10-04

First version `08d6047`, applied round `8c1829a`. Transition + DataFlow + macro: 1153 lines before, 1098 after.
All client-visible error texts are byte-identical (compared against the running server).

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| One shared bind → run → read-outputs life cycle | yes | yes | yes | kept (3/3) |
| That function belongs in the transition layer, not under `DataFlow/Binding` (it takes `WorkflowContext`) | no (kept in data layer) | yes | yes | applied (2/3): `Transition/Transitions/TransitionBody.swift`, `runBody` |
| Each kind owns its three error texts as whole literals; no `kind` / verb parameters | no | yes | yes | applied (2/3): private `failures` per kind |
| `@Input` / `@Dependency` hold a typed `Value?`, no `ValueStorage` | yes | no (`Reading` enum) | yes | applied (2/3) |
| One step → `Transition` conversion shared by the DSL helpers | yes (zip) | yes | for-loop | applied in the architecture agent's shape |
| Helper named `transitions` shadows the protocol property | – | – | yes | applied: `makeTransitions` |
| Drop redundant `where Self: TransitionProcess` | – | – | yes | applied (true redundancy) |
| Bind ask answers inside `CreateOutputStorage`, delete `BindAskInputs` | yes | no | no | rejected: changes the binding order |
| Reshape the macro (one function / `WrappedProperty` type / named helpers) | yes | yes | yes | not applied: three different shapes, no convergence |
| Renames `ReadOutputs`→`WriteOutputs`, `Ask.swift`→`Asking.swift`, move `TransitionMetadata` | – | some | some | rejected (1/3 each) |

Quotes:
- Architecture: "v1's `withBoundData` sat in the data-binding layer but took a `WorkflowContext`, kind names and
  verb fragments, so the lower layer knew the runner and the kinds, and client texts were assembled from pieces."
- Clarity: "the irregular ones (\"prepare to run action\", \"process ask\") are greppable where they belong."
- Minimality: "`@Input`/`@Dependency` are written once and only read, so they hold a plain `Value?` instead of a
  locked `ValueStorage`."

Why things are the way they are (do not "simplify" these away):
- `CreateOutputStorage` exists because a transition value is created once and copied per run; storage created in
  `Output.init` would be shared across concurrent runs (minimality).
- `@Output` / `@Ask` need the shared `ValueStorage` box because the body runs non-mutating on a copy (clarity).
- `@Ask` keeps `fatalError`: reading it in `prompt` before an answer is author misuse, not an engine bug.
- The two irregular error texts are historical per-kind wording; as whole literals they need no special cases.
- `chain(..., builderName:)` carries the name because the assertion must name the builder the author called.

Other side findings:
- An `Action` / `Condition` / `Wait` that declares `@Ask` gets empty storage and can use it as a readable output.
- `collectMetadata()` casts to `DataBindable & Defaultable` although `Defaultable` is not used, so a bindable
  process that is not `Defaultable` reports empty metadata (3/3 agents).
- The macro matches wrappers by bare attribute name: `@WorkflowEngine.Input` is skipped silently, only the first
  wrapper on a property counts, and `@DataBindable` on a `private struct` would generate a `private` `bind`.
- `WorkflowGraphBuilder`'s subflow branch duplicates `process.collectMetadata()` (relevant for S2).
- Bugs B10–B14 below.

### Server pass (S4) — done 2026-10-04

First version `4f2eb2b`, applied round: see the commit after it ("Apply critics-rewrite round to the server
cleanup"). Server module: 955 lines before, 864 after.

Safety net built for this pass: a snapshot script calling 30 cases (every error path plus the main success
shapes) and recording status, content type and body with ids/dates normalized. Compare with JSON keys sorted:
the encoder's key order differs between server runs. Baseline, first version and applied round are identical.
The script lived in the session scratchpad; worth turning into a real golden-file test.

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| The whole error contract in ONE file (v1 spread it over three) | yes | yes | yes | applied (3/3) |
| Table + middleware; engine and Core types do not conform to Hummingbird protocols | no (kept protocol) | yes | yes | applied (2/3): `Errors/ErrorResponseMiddleware.swift` |
| One helper holds the timeout policy for the three handlers | yes | split in two types | yes | kept as in v1 |
| `buildRouter` takes only `pluginRoutes` | – | yes | yes | applied |
| Remove the package-template comment in `App.swift`; file names match types | yes | noticed | yes | applied |
| Delete `ApiResponse` / `Method+HTTPRequest`, inline `App` build steps | yes | no | renamed | rejected (1/3; touches headers, needs a force unwrap) |
| `ResponseTimeout` + `TimeLimitedInstanceOperation` types | no | yes | no | rejected (1/3) |
| Extract the ask-field mapping; default host/port constants in `Config` | – | one | one | not applied (1/3 each) |

Quotes:
- Architecture: "The engine and `Core` no longer conform to HTTP concepts."
- Clarity: "Error handling is now one visible step instead of six retroactive conformances that Hummingbird
  picks up implicitly."
- Minimality, against the middleware: "`switch_case_on_newline` makes it only about 6 lines shorter, and it needs
  Hummingbird API not used in the code."

Why things are the way they are:
- Hummingbird turns an `HTTPResponseError` into a response in `RouterResponder.respond`; everything else reaches
  `Application`, which answers a bare 500 with an empty body. That is why unmapped errors have no body, and why
  the old code needed the conformances.
- The middleware must rethrow what it does not map: answering it ourselves would swallow `HTTPParserError`, which
  `Application` rethrows, and drop its "Unrecognised Error" debug log (clarity).
- Success responses have no `Content-Type` because the server never reads `DataEncodable.contentType`.
- The first `on(_:use:)` overload (returning `some ResponseGenerator`) exists only for `getInstance`, which needs
  410 and the response encoder's header.

Bugs B15–B21 below.

### Graph validation pass (S2) — done 2026-10-05

Commits: `d56657c` (local package paths, so every package builds alone), `69d3d77` (29 unit tests from the unused
fixtures), `c225c2d` (first version: analyzer with its own state), then "Apply critics-rewrite round to graph
validation". Subsystem (Graph folder, registry, `CollectMetadata`): 949 lines before, 810 after the first
version, 756 after the round.

Safety net: `Domain/WorkflowEngine/Tests/WorkflowEngineTests` (`./Tools/Run/unit_tests`). The tests compare
messages regardless of order. Checked by mutation. One mutation survived during the round: including the
cycle-closing edge in the merge broke nothing, because no fixture consumed data after a loop head. Added
`DataCarriedThroughCycleWorkflow` and `dataProducedBeforeACycleIsAvailableInsideIt` (30 tests now); the same
mutation is red with it.

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| Facts apart from rules: analysis emits no messages, the validator alone lists the checks in order | no (analyzer emits) | yes | yes | applied (2/3): `GraphTopology`, `DataAvailability`, checks in `WorkflowValidator` |
| Drop `BackEdgeKey`, the back-edge tuple, the in-stack set and `?? 0`; a cycle is found in the path | yes | yes | yes | applied (3/3) |
| Drop `Context` and `Analysis`; the builder computes required inputs and produced outputs itself | yes | yes | yes | applied (3/3) |
| Per state: types, conflicting types (sorted), keys missing on some branches | merged into one loop | yes | yes | applied (2/3) |
| Registry: one walk gives validation order and subflow cycles | yes | yes | two walks | applied (2/3): `subflowNesting()` |
| Registry: one `guard mode == .strict`; log errors without the `isValid` test | yes (log) | yes | yes | applied |
| `ambiguousAutomaticTransitions` walks states, not a dictionary (stable order) | no | yes | yes | applied (2/3) |
| Generic `DepthFirstTraversal`, `SubflowHierarchy`, `ValidationReport` types | no | yes | no | rejected (1/3; new entities around one function each) |
| Registry keeps the builder as its only graph cache | considered, rejected | yes | no | rejected (1/3) |
| Rule functions in three extension files; enum cases reordered to reporting order | no | no | yes | rejected (1/3; rules stay in one file) |
| `CollectMetadata` holds one `TransitionMetadata` (`public internal(set) var`) | yes | no | no | rejected (1/3; touches the public type) |
| Back edge detected implicitly ("source has no types yet") | yes | no | no | rejected (1/3; hides the rule) |
| Remove the dead duplicate-id check in `WorkflowRegistry.init` | yes | kept | kept | not applied: changes `throws`; see B26 |

Quotes:
- Clarity: "Split facts from rules. The builder computes facts once per workflow … and emits no messages.
  `WorkflowValidator.validate` is now a flat, ordered list of rule calls."
- Architecture: "`GraphTopology` owns structure, `DataAvailability` owns the availability rules, and neither emits
  a message. `WorkflowValidator` is the only place that lists the checks, their order and what they report."
- Minimality: "Derive instead of store. One DFS already yields everything the back-edge bookkeeping stored: the
  path gives the cycle, the finished list gives the topological order and reachability."
- Architecture: "The process id in the old back-edge key was redundant: back-edge-ness depends only on (from, to)."

Why things are the way they are:
- Message order inside one result is the same as before wherever it was deterministic: cycles, finish, dead
  ends, then per state in topological order (type conflicts, conditional inputs), then per transition (inputs),
  outputs, dependencies, subflow inputs, providers. Three places were non-deterministic before and are stable
  now: type conflicts at one state (sorted by key), ambiguous-transition warnings (state order), subflow cycles
  (found from sorted roots).
- Edge case of walking states for the ambiguous-transition warning: a transition built with the raw
  `Transition.init` from a state that is not in `states` no longer gets the warning (architecture, clarity).
- `WorkflowValidator.validate` takes the builder `inout` because it builds the workflow's own graph; subflow
  graphs are only read from the cache, and silently skipped when absent (B28).
- The `as? any DataBindable & Defaultable` cast and `try? copy.bind` in metadata collection were left alone by all
  three agents: removing them changes which processes report metadata (B29).

Verified: 30 unit tests, `full_check` 27/27, test and production builds, SwiftLint 0, production server starting
under strict validation with the six HH workflows in a sandboxed home. Bugs B22–B29 above.

### App view models pass (S5) — done 2026-10-05

Commits: `2261dd8` (23 unit tests for the Focus view models), `ff3ee5e` (first version), then "Apply
critics-rewrite round to the app view models". Focus folder plus `DrawerMessage`: 707 lines before, 678 after.

Safety net: `Apps/WorkflowApp/Tests/WorkflowAppTests`, part of `./Tools/Run/unit_tests`. `FakeServer` is a
`RestClient` with queued responses per route that ignores cancellation, and `Gate` holds a response until the
test opens it, so a test decides when a stale response arrives. Checked by two mutations, stable over six runs.
`WorkflowsService.init(rest:)` exists for these tests.

What the pass did:
- Four of the five cancellable loads share `ErrorPresenting.latest(replacing:_:)`. `take` keeps its own task.
- The mode registry is the `FocusModeID` enum (`CaseIterable`, owns its bar entry) plus an exhaustive switch in
  `FocusRoot`. `FocusModeDescriptor`, `FocusViewModel.modes` and the `fatalError` lookup are gone.
- `DrawerMessage` replaces two `errorRow` copies and two captions. `TransitionView` takes only its view model.

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| `take` without v1's `defer` (it was a regression, see below) | yes | yes | yes | applied (3/3): `take` is back to its original form |
| `take` does not fit the shared helper | plain `Task` | needs an extra `clearRunningTransition()` | "does not fit" a request/apply split | applied: helper serves the four plain loads |
| File named after its type; no doc comment on the helper | comment removed | type renamed to the file | file renamed to the type | applied: `ErrorPresenting.swift` |
| `FocusRoot.currentMode` clashes with `viewModel.currentMode` | – | noticed | inlined | applied (2/3): `let mode = switch ...` in `body` |
| Keep `AnyFocusMode` and the three mode structs | removed them | keep | keep | kept (2/3) |
| Keep `ErrorPresenting` as a protocol | keep | `LatestTask` object, no protocol | keep | kept (2/3) |
| Keep `DrawerMessage` | removed | keep | keep | kept (2/3) |
| Set `runningTransition` synchronously, drop `takeTask` | yes | "would fix the race" | no | not applied: behavior change, see B31 |
| Child view models get `service` and closures, not the parent | no | yes | no | rejected (1/3) |
| Cancel and `Task` at each call site, helper only maps the error | no | no | yes | rejected (1/3; brings the boilerplate back) |
| Mode bar table moved to `ModeBar.swift`; `if let entry`; named `workflowFinished` | – | one | two | not applied (1/3 each) |

Correction of my own first version: its commit message says the `defer` in `take` only changes an unreachable
path. All three agents showed it is reachable. Architecture: "Two quick takes both pass the guard, and the
cancelled first one hides the running row while the second is in flight." The round restores the original
`take`; the underlying race is B31.

Quotes:
- Clarity: "v1's `latest(replacing:_:)` hid two unrelated decisions in one helper: 'cancel the previous call' and
  'show the failure text'. The first is one half of 'latest wins'; the other half (`try Task.checkCancellation()`)
  sat at the call site." (Noted, not resolved: the two proposed fixes point in opposite directions.)
- Architecture: "`AnyFocusMode` looks load-bearing: all three modes return `ActiveWorkflowContent`, so the
  `AnyView` keeps identity and `.blurReplace` in `FocusHUD` does not fire on mode change."
- Clarity: "a top-level switch over modes would give `FocusHUD` a new identity per mode and reset its
  `@FocusState` and tint."
- Minimality: "`ActiveWorkflowContent` stays a separate view: it keeps `activeWorkflow` observation out of
  `FocusRoot.body`." And: `SwitchViewModel.activate` sets the workflow unanimated before the animated
  `enter(.initial)`; "if `FocusRoot.body` read `activeWorkflow`, the mode change could lose `.snappy`."

Why things are the way they are:
- `error` of both view models is settable inside the module because the protocol needs the setter.
- Mode bar order is now the declaration order of `FocusModeID` cases (was an explicit array); the test
  `modeBarOffersSwitchingAndTransitionWithTheirShortcuts` pins it.
- After a take that finishes the workflow, `refresh()` runs twice (from `take` and from `.task(id:)`); both hit
  the no-workflow guard and send nothing (clarity).
- Dead leftover for the user's decision: `ModeBar.placeholderButton("doc.text")` (minimality, architecture).

Verified: 23 app tests, all unit tests, `build_app`, SwiftLint 0. NOT verified: the look and animations of the
HUD on screen; the app was not launched. Bugs B30–B33 above.

### Storage pass (S6) — done 2026-10-10

Commits: `d15d9b4` (14 storage tests), `c54610d` (first version: one instance table behind both storages),
then "Apply critics-rewrite round to the storages". Storage folder: 196 lines before, 213 after the first
version, 196 after the round, with the list logic existing once instead of twice.

Safety net: `WorkflowStorageTests.swift` in the engine test target: 7 tests run against both storages, 7
against the JSON file storage (files, format, reload, skipped files, eviction of files). Retention `-1`
means "evict at once", so nothing sleeps. Checked by two mutations, stable over three runs.

| Idea | Minimality | Architecture | Clarity | Decision |
|---|---|---|---|---|
| Creating an instance and stamping `finishedAt` belong on `WorkflowInstance`, not on the table | on the table (`create`) | yes | yes | applied (2/3): `init(atStartOf:data:)` and the `finished(at:)` modifier in `WorkflowInstance.swift` |
| Table rows private, `= []`, `init(retentionInterval:)` only | yes (memberwise) | yes | yes | applied (3/3) |
| `put` is remove-and-append, not filter-and-concatenate | kept | yes | yes | applied (2/3) |
| No `_ =`: eviction result is discardable | kept `_ =` | `@discardableResult` | no ids returned at all | applied (2/3 against `_ =`) |
| Load files inside the actor, not a static function with a `logger:` parameter | noted as a finding | yes (in a struct) | yes | applied (2/3): `loadInstanceFiles()` from the async init |
| Decoder as a stored property beside the encoder | – | yes | yes | applied (2/3) |
| Eviction as one deadline comparison | yes | no | no | rejected (1/3) |
| Each actor loops over `expired(at:)` and removes rows itself | no | no | yes | rejected (1/3) |
| A `WorkflowInstanceDirectory` struct for all file concerns | no | yes | no | rejected (1/3; new entity around four functions) |
| `fileURL(for:)`, `store(_:)` = put + save | – | one | one | not applied (1/3 each) |

Quotes:
- Clarity: "The table only knows rows and the retention rule; every scenario is spelled out top-to-bottom in
  the storage that owns it."
- Architecture: "The 'evict on finish/all/instance' points stay in the actors because they are the storage
  contract, not a property of the list."
- Minimality, on the static load: "`load` is static with a `logger:` parameter only because `table` must be
  initialized before `self` can be used in the init."
- Clarity, on the async init: "`JSONFileWorkflowStorage.init` has no `await` inside; its `async` is now
  load-bearing (it is what makes the init isolated so `loadInstanceFiles` can touch `table`/`logger`)."

Why things are the way they are:
- `JSONFileWorkflowStorage.init` stays `async` although nothing awaits: an async actor initializer is isolated
  once every stored property is set, which lets it call the isolated `loadInstanceFiles()`.
- Eviction points (finish, all, instance) are in both actors on purpose; they are the storage contract.
- `WorkflowInstance.swift` had kept the header `WorkflowRun.swift` from a rename; fixed in passing.

Verified: 44 engine tests, `full_check` 27/27, prod build, SwiftLint 0. Bugs B34–B36 above.

### Bugfix phase — 2026-10-10

Twenty-five backlog items fixed in sixteen commits (table in the backlog section), each with a test where the
suite can reach the behavior, each test checked red before the fix by reverting the sources. New test
targets: `Core/Rest/Tests/RestTests`; new tests in the engine (optional output, storage order and failed
writes, three validator cases) and the app (five view model cases). `Tools/Run/unit_tests` runs four
packages now: Core 3, Rest 3, engine 50, app 28. Integration suite: 28 scripts (`run_unicode_workflow_id`
is new; `run_http_edge_cases` checks content type and the error shape).

Behavior changes a client can see:
- HTTP error texts now name the ids involved and equal the stored `transitionState.failed` text.
- Success responses carry `Content-Type: application/json`; the graph endpoint's 404 is an `ErrorResponse`.
- Field arrays in the graph DTO and `expectedFields` are sorted by key.
- Validation messages changed (see B24); strict validation of the six HH workflows still passes.
- Percent-encoded workflow ids in paths work.

Verified at the end: all unit tests, `full_check` 28/28, prod build, app build, SwiftLint 0, production
server start under strict validation in a sandboxed home.

## Proposed order

1. ~~Dead-code sweep~~ — done, see progress log.
2. ~~Architectural pass: A1~~ — done, see progress log. A2 moves into S1.
3. Subsystems: ~~S1 runner~~, ~~S3 transition kinds and binding~~, ~~S4 server~~, ~~S2 graph validation~~,
   ~~S5 app view models~~, ~~S6 storage~~ (done). S7 Google auth skipped (user, 2026-10-10: storage, then
   bugfixes): half of its duplication is the unreferenced `ServiceAccountTokenProvider`.
4. ~~Bug backlog B1–B36~~ — done except the five that need a decision (B1, B8, B16, B26, B29) and B6/B36.
5. Decisions on the leftovers (unreferenced code, marks, B1/B8/B16/B26/B29), then the pull request.
