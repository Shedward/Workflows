---
type: task
status: open
---

# An `Ask` that branches on the answer

`Asking` waits for an answer and continues to one state; `Condition` picks a
target with `check()` but cannot wait. "Approve or send back?" therefore
takes two transitions today: an `Ask` that writes the answer to an
`@Output`, then an automatic `Condition` that reads it, plus a routing-only
state between them in the `State` enum.

Wanted: one transition kind that asks, waits, and routes on the answer
(`Asking` with `possibleTargets` and a `check()` run after the answer, or a
combined protocol), so the graph shows the branches leaving the question
itself.

Touches: `TransitionBody` / `Asking.start`, `WorkflowGraph` and its API
mapping (`asking` with `targets`), validation (`DataAvailability` across the
branches), the app's asking view. Sugar over what already works; take it
when `HHWorkflows` has three or more Ask → Condition pairs.

## Notes

From `.claude/notes/2026-04-04-branching-and-ask.md:86` ("architecturally
possible, Asking + Condition aren't mutually exclusive"). Sources:
`Transition/Transitions/Ask.swift` (`Asking`), `Condition.swift`
(`possibleTargets`, `routedTarget`).

## Changelog

- Заведено при сканировании заметок 2026-10-11.
