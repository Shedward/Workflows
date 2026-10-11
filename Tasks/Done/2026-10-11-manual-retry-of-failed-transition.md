---
type: task
status: done
effort: medium
impact: high
---

# Let the user retry a failed transition

A transition that throws leaves the instance in `transitionState.failed` for
good; the only way out is deleting the instance file. Add a manual retry:
`POST /workflowInstances/:id/retry` clears the failed state and runs the same
transition again with the same instance data, through the normal
`takeTransition` path (so automatic chains continue as usual).

Scope: manual retry only, no automatic retries or back-off. Idempotency is
the action's own business: an `Action` that created a Drive file before
failing will create a second one on retry, and the engine does not try to
know that.

Deliverables: runner method, REST endpoint and `API.md` entry, a button in
the app's failed-transition view, an integration test with a workflow that
fails once and succeeds on retry (`FailingWorkflow` or a counter dependency).

Done: `WorkflowRunner.retry(instanceId:)` (`WorkflowRunner+Retry.swift`)
takes the transition recorded in `transitionState.failed` again under the
instance lock via `takeTransitionLocked`, with the pre-failure data, and the
automatic chain continues on success. `WorkflowsError.InstanceNotFailed`
(409) when there is nothing to retry. `RetryTransition` in `Domain/API`, the
controller route, `API.md`. Test workflow `FlakyWorkflow` (`FailOnceAction`
fails the first time it sees an `attemptKey`), `Tools/Tests/run_retry_transition`.
App: `TransitionViewModel.failure()` / `retry()`, a card with the error and a
Retry button in `TransitionView` instead of the transition list.

## Notes

Known gap since `.claude/notes/2026-03-29-improvements.md:63` and CLAUDE.md
Known Issues ("No retry mechanism for failed transitions"). Half of the
transitions call external services (git, Google) that fail on the network, so
one failure on step five currently means restarting the workflow by hand.
Related: `2026-10-11-unify-failure-persistence-in-runner` (the failed state
this endpoint clears).

## Logs

- 2026-10-11: Заведено при сканировании заметок.
- 2026-10-11: Оценено effort medium (runner, endpoint, кнопка в app,
  интеграционный тест), impact high (сетевой сбой на пятом шаге сейчас =
  перезапуск руками).
- 2026-10-11: Выяснено: упавший ручной переход и раньше повторялся обычным
  `takeTransition` (он не смотрит `transitionState`); навсегда застревал
  только автоматический. Отдельный `/retry` оставлен — ему не нужен
  `processId`. Дыра в `takeTransition` вынесена в
  `2026-10-11-take-transition-ignores-trigger-and-transition-state`.
- 2026-10-11: Сделано: runner, эндпоинт, `FlakyWorkflow`,
  `run_retry_transition`, карточка с Retry в app, тесты view model.
  `full_check` и `unit_tests` зелёные, в app проверено руками.
