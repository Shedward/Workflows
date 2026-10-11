# 2026-10-11 — беклог переезжает в `Tasks/`

Гриль по системе ведения задач (формат, статусы, история, аналоги, оформление).
Решения и отвергнутые варианты — ADR
`~/.claude/docs/personal-skills/adr/0001-tasks-as-markdown-files-without-tooling.md`,
термины — `~/.claude/docs/personal-skills/CONTEXT.md`.

Сделано:
- Личный скилл `tasks` (`personal-skills/skills/tasks/`: SKILL.md + TEMPLATE.md);
  строки-интеграции в `harvest`, `troubleshoot`, `critics`. Правила, добавленные
  по ходу: простую правку предлагать сделать сразу вместо задачи; решённое
  «не делать» класть сразу в `Done/` как `dropped` с причиной; `harvest`
  пробегает открытые задачи и предлагает дописать находки сессии.
- `Tasks/` в корне репо (регистр как у соседних папок), первые задачи — хвосты
  беклога чистки: B19 → `env-override-bypasses-oauth-redirect-uri`, B36 →
  `storage-silently-accepts-unknown-and-finished-ids`. B6 оказался закрыт в
  dead-code sweep.
- `CLAUDE.md` Known Issues указывает на `Tasks/`; таблица «Bug backlog» в
  заметке 2026-10-04 — история.

## Скан баз знаний (та же сессия)

Explore-агент прошёл 14 заметок, `~/.claude/docs/Workflow`, `Documentation/`:
большинство старых планов сделано, 27 кандидатов разобраны по одному.

Заведено 15 открытых (`ls Tasks/`): 8 багов, 6 задач, 1 decision. Закрыто сразу
как `dropped` в `Tasks/Done/`: timeout для wait (by design, ждём человека),
event queue runner (нет ни одного триггера).

Сделано кодом вместо задач:
- `ErrorDescription.init(error:)` переехал из `Domain/API` в серверный маппинг
  `ErrorDescription+API.swift` как `init(model:)`; `API` без `import Core` в
  этом файле.
- REST `trigger` отдаётся через `TransitionTrigger.apiValue` (явные wire-строки),
  не `rawValue`.
- Переименования контракта: `API.Workflow.stateId` → `states`,
  `waitingWorkflow(workflowId:)` → `waitingWorkflow(instanceId:)`; `API.md`,
  `run_subflow_workflow`, `run_subflow_lifecycle` обновлены.
- `Documentation/Architecture.md`: секция «Workflow DSL — state conventions»
  про неявные `_start`/`_finish` и имена состояний.

Пропущено по решению пользователя: golden-file тест REST-ответов (много кода,
мало смысла).

Мелочи из скана, сделаны в конце сессии: `Core` объявлен в
`Apps/WorkflowServer/Package.swift` (задача закрыта в `Tasks/Done/`);
строка Known Issues про `try?` в раннере удалена (`try?` там нет); карта
`workflow-engine-graph-validation.md` сверена с `main@2026-10-11`
(билдер кэширует только `WorkflowGraph`, `ResumeReason` top-level, ссылки
на задачи).

Не проверено сборкой (правило пользователя): `./Tools/Run/full_check` должен
пройти, смена JSON-контракта покрыта двумя subflow-скриптами. Коммиты в
обоих репо — за пользователем.
