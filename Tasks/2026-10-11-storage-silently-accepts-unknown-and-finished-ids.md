---
type: bug
status: open
---

# Storage `update`/`finish` silently accept unknown ids and re-finish finished instances

`WorkflowInstanceTable.put` removes any instance with the same id and appends
the new one, so both storages:

- `update` / `finish` of an id that was never created add it as if created;
- `finish` of an already finished instance overwrites `finishedAt`, restarting
  retention;
- with `retentionInterval <= 0` the file storage's `finish` writes the file
  and evicts it at once (tests rely on `-1` for "evict immediately"; `0` would
  be flaky).

Expected: unknown ids throw, a second `finish` is rejected or a no-op, and
retention `0` has one defined meaning.

## Notes

B36 from the 2026-10 storage round, read from code and not reproduced by
experiment. Left out of the cleanup as minor; still true on `main` after
PR #18 (`Domain/WorkflowEngine/Sources/WorkflowEngine/Runtime/Storage/WorkflowInstanceTable.swift`).

## Changelog

- Заведено из «Bug backlog» B36 в `.claude/notes/2026-10-04-cleanup-exploration.md`
  при переносе беклога в `Tasks/`.
