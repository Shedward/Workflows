---
type: task
status: open
---

# Persist a failed transition in one place of `WorkflowRunner`

A failed transition is written to storage at three sites, each with its own
answer to the double fault (the storage write fails too):

- `executeTransitionLocked`: throws `Failure("... instance is in an unknown state")`;
- `executeAutomatic`: logs and returns `nil`, halting the chain;
- the automatic-chain loop: logs and returns the `failed` instance.

A failed automatic step is therefore written twice (step, then loop), and the
instance's state after a storage fault depends on whether the step was manual
or automatic. Let the step report whether the process or the engine failed and
persist once, with one double-fault policy.

Take it together with a unit test "storage throws on the failure write" for
both the manual and the automatic path; there is none today.

## Notes

B7 follow-up (`.claude/notes/2026-10-04-cleanup-exploration.md:162`, 2/3
critics for it, the minimality critic against as a restructuring for
symmetry). Sources:
`Domain/WorkflowEngine/Sources/WorkflowEngine/Runtime/Runner/WorkflowRunner.swift`,
the `do { try await storage.update(failed) }` blocks. This is the area of the
B7 (chain loop) and B10 (race) fixes, so keep the lock discipline intact.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
