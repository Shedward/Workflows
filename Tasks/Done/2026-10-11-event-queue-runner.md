---
type: task
status: dropped
---

# Rebuild the runner around an event queue

Evaluated in the March 2026 code review: transitions, wait signals, answers
and failures as events in one `AsyncStream`, a single drain loop with
`handle(_:)`, settlement through continuations. A targeted fix solved the
problem of the day instead.

The note that evaluated it lists the conditions under which it becomes
worth it: parallel transition execution, external event sources / webhooks,
live state observation over SSE / WebSocket, retry policies with back-off
and saga-style compensation. It also keeps the design notes for that day
(enum event types, `EventContext` with trace ids and retry counts,
`AsyncStream` continuations for multiple observers, per-event catch so the
queue is never poisoned, `Task.yield()` between events, the `isProcessing`
flag and continuation-leak pitfalls): see
`.claude/notes/2026-03-21-code-review.md:71-87`.

## Notes

Dropped on 2026-10-11 (user): none of the four triggers is planned. The
runner is an actor with a per-instance lock, the only client polls, retry is
being added as a manual action
(`2026-10-11-manual-retry-of-failed-transition`). Reopen when the first
trigger appears, starting from the design notes above.

## Logs

- 2026-10-11: Заведено при сканировании заметок и сразу закрыто: нет
  триггера.
