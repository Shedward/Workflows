---
type: task
status: open
---

# Keep a per-instance history of executed transitions

An instance carries only its current state and `transitionState`. "How did
it get here and how long did each step take" is answerable only from the
server's system log, which the sandbox cannot read. Record an event per
executed or failed transition, `(timestamp, transitionId, state, durationMs,
error?)`, persist it with the instance, serve it as
`GET /workflowInstances/:id/history`, and show it in the app as a timeline.

Bound the size: the last N events, or only the events since the last
`_start`.

## Notes

From the multi-lens review (`.claude/notes/2026-04-07-multi-lens-review.md:86,111,132`,
"Minimal observability … no per-instance traces"). What exists today:
`traceId` and the transition-updates plugin (`WorkflowTransitionUpdatesPlugin`),
which already sees every event this needs but persists nothing. Low priority
while there are one or two production workflows and `log show` is bearable.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
