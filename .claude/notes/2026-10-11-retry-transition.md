# 2026-10-11 — ручной retry упавшего перехода

Первая сессия из Xcode (ветка `manual-retry-of-failed-transition`, от main после
PR #19 `tasks-backlog`).

Сделано (задача закрыта в `Tasks/Done/2026-10-11-manual-retry-of-failed-transition.md`):
- Движок: `WorkflowRunner.retry(instanceId:)` в `WorkflowRunner+Retry.swift`,
  `Workflows.retry(_:)`, ошибка `InstanceNotFailed` (409). `takeTransitionLocked`
  и `loadInstance` стали internal — вынос в extension из-за `file_length`.
- API/сервер: `RetryTransition`, `POST /workflowInstances/:id/retry`, `API.md`,
  CLAUDE.md (эндпоинт, Known Issues).
- Тесты: `FlakyWorkflow` / `FailOnceAction` (падает на первом `attemptKey`,
  без DI — `Mutex<Set<String>>`), `run_retry_transition`, хелперы `retry` /
  `try_retry` в `workflow.sh`.
- App: `WorkflowsService.retryTransition`, `TransitionViewModel.failure()` /
  `retry()`, карточка ошибки с Retry в `TransitionView`, мок
  `WorkflowInstance.Mock.failed`, 3 теста view model.

Решения:
- Отдельный `/retry`, а не «чинить через `takeTransition`»: ручной упавший
  переход и так повторялся `takeTransition`, застревал только автоматический.
- `failure()` — метод view model; не свойство VM и не свойство доменной модели
  `API.WorkflowInstance` (пользователь отверг оба).

Найдено и заведено: `Tasks/2026-10-11-take-transition-ignores-trigger-and-transition-state.md`.

Проверено: `full_check` (29/29), `unit_tests`, SwiftLint; app руками против
`workflow-server-testing`. Xcode держит два запуска разных схем параллельно
(сервер + app) через `XcodeSwitchScheme` + `RunProject`.

Коммит — за пользователем.
