---
type: decision
status: open
effort: low
impact: medium
---

# Should a subflow that declares no `@Input` keep receiving the whole parent `WorkflowData`?

`Subflow.filteredData(from:)` returns the parent data unchanged when the
subflow's `collectMetadata().inputKeys` is empty; only a subflow that declares
at least one `@Input` is filtered to its declared keys (with a warning for the
keys it drops). So the data contract of a subflow is opt-in: an empty
declaration means "everything", not "nothing".

Options:

1. **Keep the pass-through** as the convenient default and document it in
   `Architecture.md` next to the DSL rules. Cheapest; the subflow's inputs
   stay invisible to graph validation, so a renamed parent key breaks the
   child at runtime, not at startup.
2. **Phase 2 of the April plan**: an empty declaration means empty data, a
   subflow reading a key it did not declare is a validation error, every
   subflow states its contract. Makes `DataAvailability` exact across
   subflow boundaries; breaks every testing workflow that relies on the
   pass-through (how many: not checked).
3. **Middle**: keep the pass-through at runtime but have the validator warn
   on a subflow with no `@Input` that is reachable from a parent carrying
   data. No breakage, nudges toward declaring.

## Notes

From the multi-lens review
(`.claude/notes/2026-04-07-multi-lens-review.md:108,133`, "Enforce subflow
I/O through declared @Input/@Output (Phase 2)"); CLAUDE.md Known Issues
records the current behaviour as "Subflow data isolation is opt-in". Source:
`Domain/WorkflowEngine/Sources/WorkflowEngine/Transition/Transitions/Subflow.swift`
(`filteredData`, `declaredInputKeys.isEmpty` guard).

## Changelog

- Заведено при сканировании заметок 2026-10-11.
- Оценено effort low (варианты расписаны, осталось выбрать), impact medium
  (определяет контракт всех subflow и точность валидации).
