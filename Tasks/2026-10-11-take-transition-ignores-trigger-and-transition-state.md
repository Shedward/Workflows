---
type: bug
status: open
effort: low
impact: medium
---

# `takeTransition` ignores the transition's trigger and the instance's `transitionState`

`WorkflowRunner.takeTransition` resolves the transition only by
`$0.from == instance.state && $0.id.processId == processId` and runs it. It
checks neither `transition.trigger` nor `instance.transitionState`, so a
client can:

- take an automatic transition by its `processId`, as if it were manual;
- take a transition while the instance is `executing` or waiting (time, subflow,
  ask): the state does not change during a wait, so the same transition is
  available again, and a waiting subflow transition taken twice starts a second
  child instance.

Expected: only manual transitions, and only when `transitionState` is `nil`
or `failed` (repeating a failed manual one stays allowed, see
`run_failed_transition`). Otherwise 409 `TransitionProcessNotFoundForInstance`
or a dedicated error. `GET .../transitions` should agree with the same rule.

## Notes

Found while doing `Done/2026-10-11-manual-retry-of-failed-transition`: the
runner code was read, the subflow-twice scenario was not reproduced. Add the
cases to `Tools/Tests/` (automatic by id, during a wait, during an ask).

## Logs

- 2026-10-11: Заведено при работе над retry. Effort low (одна проверка в
  `takeTransition` плюс фильтр в `transitions(for:)` и тесты), impact medium
  (клиент может запустить второй subflow или обойти wait).
