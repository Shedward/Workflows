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

## Proposed order

1. ~~Dead-code sweep~~ — done, see progress log.
2. Architectural pass: A1, then A2.
3. Subsystems: S1, S2, S3, then S4, S5; S6 and S7 if still worthwhile.
