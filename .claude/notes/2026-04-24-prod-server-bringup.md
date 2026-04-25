# 2026-04-24 — Prod server bring-up & UX polish

Four threads of work in one session, all on the `focus-ui` branch.

## 1. iOS picker uses WorkflowStart instead of raw workflow IDs

The iOS app's start flow was calling `GET /workflows` and rendering raw `workflow.id` strings. Each workflow already exposes a richer `WorkflowStart` mechanism via `WorkflowStartProvider` — start values carry a human-readable `title` and pre-populated `data`. Switched the picker to a flat list of all `WorkflowStart` values across all workflows.

**Changes:**
- New `API.WorkflowStart` model — `{ id, workflowId, title, data }`. `id` is a server-generated UUID (workflowId+title was rejected as not unique enough). Replaces the old `WorkflowStartCandidate` (which carried `inputs` metadata that nothing consumed).
- New `GET /startingWorkflows` flat endpoint backed by `Workflows.allStarting()`. Existing `GET /workflows/:id/starting` updated to return the same `WorkflowStart` shape.
- Engine `Workflows+Starting.swift` simplified — `starting(for:)` returns `[WorkflowStart]` directly; new `allStarting()` aggregates across all workflows.
- iOS: `WorkflowsService.getStartingWorkflows()`, `FocusViewModel.State.selectingWorkflow([WorkflowStart])`, `WorkflowPicker` shows `start.title ?? start.workflowId` tinted by `start.workflowId.tint`.
- Tests: updated `run_starting`; added `run_get_starting_workflows`; registered in `run_all`. All 26 integration tests pass.

User later added a secondary `workflowId` caption under the title in `WorkflowPicker`.

## 2. `run_server` / `build` accept `test` | `prod`, with graceful restart

Previously hardcoded to `workflow-server-testing`. Now both scripts accept a positional environment arg:
- `test` (default) → scheme `workflow-server-testing` (TestingWorkflows + InMemoryWorkflowStorage)
- `prod` → scheme `workflow-server` (HHWorkflows + JSONFileWorkflowStorage)

`run_server` also looks up any process listening on `tcp:8443`, sends SIGTERM, polls up to ~5s, falls back to SIGKILL — so `run_server` now stops a running server before launching the freshly built one. By port, not by name, so it works across schemes and catches stray instances from interrupted `full_check`.

`Tools/Run/full_check` still calls `build` with no args → unchanged behavior. CLAUDE.md updated.

## 3. Pretty-print `WorkflowsError` on startup failure

Validation failures used to dump raw struct reflection (single line, nested initializers, hard to read with Cyrillic ids). Replaced with formatted output via existing `Core.DescriptiveError` protocol — chosen over a one-off entry-point check so any future error gets nicer presentation by adding conformance.

**Changes:**
- `Core/Core/Sources/Core/Errors/ReportFatalAndExit.swift` — generic handler: prints `userDescription` for `DescriptiveError`, falls back to `"\(error)"`, exits 1.
- `Domain/WorkflowEngine/Sources/WorkflowEngine/Workflows/WorkflowsError+DescriptiveError.swift` — `WorkflowsError.ValidationFailed: DescriptiveError`, formatted output with `-` bullets, no colors, soft-wrap at ~80 cols, omits workflows with zero errors+warnings.
- Both server entry points wrapped in `do { try await runServer() } catch { reportFatalAndExit(error) }`.

Format example:
```
Workflow validation failed - 1 workflows have errors

  Работать_над_портфелем
    errors (4):
      - No path from start to finish exists
      - State 'аб_тест' has no outgoing transitions and is not a finish state
      ...
    warnings (2):
      - Cycle detected involving states: разработка → тестирование
      - State 'ждет_релиза' is declared but never used in any transition
```

Other `WorkflowsError.*` types (`WorkflowNotFound`, etc.) intentionally not converted yet — opt in when there's a need.

## 4. Wired Google Drive/Sheets into prod server

Validation showed `Создать_таблицу_для_декомпозиции` failing with missing `googleDrive` / `googleSheets` dependencies. Fixed by:
- `import GoogleServices` in `Projects/workflow-server/workflow-server/App.swift`.
- Loading `GoogleOAuthCredentials` from `~/.workflows/google_cloud/oauth_client.json`.
- Building one shared `UserOAuthTokenProvider` (Drive + Sheets scopes, callback `https://127.0.0.1:8443/auth/google/callback`).
- Registering the provider on `authRegistry`.
- Passing `GoogleDriveClient(tokenProvider:)` and `GoogleSheetsClient(tokenProvider:)` into `DependenciesContainer` keyed `"googleDrive"` / `"googleSheets"` (matches `@Dependency var googleDrive` / `var googleSheets` property names in `HHWorkflows` actions).

No `pbxproj` edits needed — Xcode auto-resolves `GoogleServices` through the workspace's `FileSystemSynchronizedGroup` for `Services/`.

Build clean. After fix, `Создать_таблицу_для_декомпозиции` validation passes.

## What's left for prod

Next session: `Работать_над_портфелем` graph topology errors:
- No path from start to finish.
- State `аб_тест` has no outgoing transitions and is not a finish state.
- Subflow `Декомпозиция_портфеля` requires input `portfolioKey` that isn't available at state `декомпозиция`.
- (Plus warnings about cycles and unused states.)

The redirect URI assumes the GCP OAuth client is "Web application" type with `https://127.0.0.1:8443/auth/google/callback` registered. If the file is `installed`-keyed (Desktop app), the URL convention may differ — flagged with the user, not yet verified.
