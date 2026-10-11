---
type: bug
status: done
effort: low
impact: low
---

# `Core.withTimeout` traps on `nan` or infinite `seconds`

`withTimeout(seconds:operation:)` passes `seconds` straight into
`Task.sleep(for: .seconds(seconds))`, which traps for `nan` and `.infinity`.
The only caller today, `WorkflowInstancesController`, clamps the value it
reads from the `?timeout` query (B15), so the public `Core` function is
protected by its caller rather than by itself.

Expected: `withTimeout` itself rejects or clamps non-finite input (a
precondition with a message, or treating non-finite as "no timeout"), with a
unit test in `Core/Core/Tests`.

## Notes

Remainder of B15 (`.claude/notes/2026-10-04-cleanup-exploration.md:199`).
Source: `Core/Core/Sources/Core/Concurrency/WithTimeout.swift`. Not
cancelling the operation on timeout is intentional and documented there; this
task does not touch that.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
- Оценено effort low (precondition плюс юнит-тест), impact low
  (единственный вызов уже защищён clamp'ом).
- Сделано: non-finite `seconds` означает «без дедлайна» (таймер не
  запускается), параметризованный тест в `CoreTests`. Clamp в контроллере
  остаётся: он ещё защищает от огромных конечных значений вроде `1e30`.
