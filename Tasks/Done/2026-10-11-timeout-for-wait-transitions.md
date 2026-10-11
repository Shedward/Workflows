---
type: task
status: dropped
---

# Deadline for `Wait` / `Subflow` / `Ask` transitions

A waiting transition stays waiting until its signal arrives: a point in
time, the child instance finishing, or an answer to an `Ask`. If the signal
never comes, the instance is listed as running forever. The idea was an
optional `.timeout(...)` on the transition, after which it fails or takes a
timeout branch, built on `WaitScheduler`.

## Notes

Dropped on 2026-10-11 (user): waiting forever is the intended behaviour. A
`Wait` waits for a human action, and a human may take any amount of time;
turning that into a failure or a branch would make the workflow lie about
what happened. Deadlines and reminders are a different feature (notify, do
not fail) and may be considered later as their own task.

CLAUDE.md Known Issues lists "No timeout for wait transitions"; that line
describes a design choice, not a gap.

## Logs

- 2026-10-11: Заведено при сканировании заметок (идея из
  `.claude/notes/2026-03-29-improvements.md:65`) и сразу закрыто как won't fix.
