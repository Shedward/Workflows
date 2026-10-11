---
type: bug
status: open
effort: medium
impact: low
---

# `@Ask` declared on an `Action` / `Condition` / `Wait` silently acts as an output

`CreateOutputStorage.ask(for:at:)` gives every `@Ask` property a fresh
`ValueStorage`, and `runBody` applies it to any `DataBindable` process, not
only to `Asking` ones. So an `Action` that declares `@Ask var answer: String`
compiles, gets empty storage, can be written like an `@Output`, and
`CollectMetadata` even lists the key under `outputs`. The author gets no
diagnostic that the prompt never happens.

Expected: `@Ask` outside an `Asking` process is a validation error (the graph
builder sees the `asks` metadata and the transition kind), or the engine
refuses to bind it at runtime with an explained failure.

## Notes

Side finding of the cleanup critics
(`.claude/notes/2026-10-04-cleanup-exploration.md:455`). Sources:
`DataFlow/Binding/Bindings/CreateOutputStorage.swift`,
`Transition/Transitions/TransitionBody.swift` (`runBody`),
`CollectMetadata.ask` inserting the field into `outputs`. Not reproduced.

## Logs

- 2026-10-11: Заведено при сканировании заметок.
- 2026-10-11: Оценено effort medium (проверка в валидаторе плюс фикстура),
  impact low (ошибка авторская, в проде не встречалась).
