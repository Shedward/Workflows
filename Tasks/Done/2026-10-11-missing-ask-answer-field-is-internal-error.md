---
type: bug
status: done
effort: low
impact: medium
---

# An answer that lacks an expected `@Ask` field fails as an internal error, not as an invalid request

The submitted answer was not checked against `expectedFields` before the
transition resumed. `BindAskInputs.ask(for:at:)` then threw a plain
`Failure("Ask input \(key) is not provided")` from inside `runBody`, i.e. from
inside the transition's own execution: the server answered 500 with the
engine's wording, and the failure went down the same path as a process
failure. The caller's mistake belongs to the `invalidRequest` group (400),
like the other client errors (CONTEXT.md rule: four semantic groups), and
must not touch the instance.

Fixed: `WorkflowRunner.answerAsk` compares the answer's keys with
`Waiting.Asking.expectedFields` before resuming and throws
`WorkflowsError.MissingAskAnswers` (`kind: .invalidRequest`, lists the
missing keys). `BindAskInputs` keeps its check as the last line of defence.

## Notes

Known since the Ask design note (`.claude/notes/2026-04-04-branching-and-ask.md:87`,
"no server-side check that the answer contains all expected fields"). Pattern
followed: the error types introduced for B16 (`Semantic HTTP statuses for
client mistakes`). Whether the pre-fix path also persisted
`transitionState.failed` was read from `runBody` / `Failure.wrap`, not
verified by experiment; the new `run_ask` case asserts the instance stays
asking after a rejected answer.

## Logs

- 2026-10-11: Заведено при сканировании заметок.
- 2026-10-11: Оценено effort low (один тип ошибки по образцу B16 плюс тест),
  impact medium (клиент получает 500 и текст движка на свою ошибку).
- 2026-10-11: Сделано: проверка ключей до resume в `answerAsk`, новый тип
  ошибки, случай в `run_ask`, строки в `API.md`. Тело переписано: ошибка
  возникала внутри исполнения перехода, а не только маппилась в 500.
