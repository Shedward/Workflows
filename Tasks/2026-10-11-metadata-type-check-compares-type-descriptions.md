---
type: bug
status: open
effort: medium
impact: low
---

# Graph validation compares value types by `String(describing:)`

`CollectMetadata` records every `@Input` / `@Output` / `@Ask` field as
`DataField(key:valueType: String(describing: Value.self))`, and
`DataAvailability` matches producers to consumers on that string. Two types
with the same description but different identity, or `Optional<String>` vs
`String` where the engine would actually bridge, are judged by their printed
name: a mismatch the engine tolerates at runtime can be reported as an error,
and a real mismatch between same-named types from different modules passes.

Expected: compare `ObjectIdentifier(Value.self)` (or `Any.Type` equality) and
keep the description only for messages; a validator test with a fixture that
produces `String?` and consumes `String`.

## Notes

Known since the graph validation note
(`.claude/notes/2026-03-29-graph-validation.md:75`). Source:
`Domain/WorkflowEngine/Sources/WorkflowEngine/DataFlow/Binding/Bindings/CollectMetadata.swift`
and the `DataField` type above it. Not reproduced; whether the engine
actually bridges `String?` to `String` at runtime is not verified.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
- Оценено effort medium (замена сравнения, фикстура, проверить bridging
  `String?`), impact low (ложных срабатываний не видели).
