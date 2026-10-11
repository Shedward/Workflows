---
type: task
status: open
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
