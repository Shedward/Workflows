---
type: bug
status: open
effort: medium
impact: low
---

# `@DataBindable` matches property wrappers by bare attribute name

`DataBindableMacro.bindingMethods` is a table keyed by the attribute's bare
identifier (`Input`, `Output`, `Dependency`, `Ask`). Consequences:

- `@WorkflowEngine.Input var x` is skipped silently: the property gets no
  `bind` statement and graph validation never sees the input.
- Only the first wrapper on a property counts; a second one is ignored.
- `@DataBindable` on a `private struct` copies the `private` modifier onto the
  generated `bind`, which then does not satisfy the `DataBindable` requirement.

Expected: a qualified name resolves like the bare one, every wrapper on a
property is bound or a diagnostic is emitted, and the generated method's
access level satisfies the protocol regardless of the type's modifier.

## Notes

Found by the critics round of the cleanup
(`.claude/notes/2026-10-04-cleanup-exploration.md:458`, "Reshape the macro"
was not applied). Source:
`Domain/WorkflowEngine/Sources/WorkflowMacroImpl/Macros/DataBindableMacro.swift`
(`bindingMethods`, `extractField`, access-level computation in `expansion`).
Not reproduced; read from the macro source.

## Logs

- 2026-10-11: Заведено при сканировании заметок.
- 2026-10-11: Оценено effort medium (правка макроса и тесты), impact low
  (квалифицированные имена обёрток никто не пишет).
