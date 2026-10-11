---
type: bug
status: done
---

# `WorkflowServer` imports `Core` without declaring the dependency

`Apps/WorkflowServer/Package.swift` lists `Rest`, `WorkflowEngine` and `API`
as the target's dependencies, yet `AuthController`, `PluginController`,
`InvalidRequestBody`, `ErrorResponseMiddleware` and
`WorkflowInstancesController` all `import Core`. It compiles only because
`Core` arrives transitively through `Rest`; a stricter SwiftPM or a change in
`Rest`'s product would break the build.

Expected: `.product(name: "Core", package: "Core")` in the target's
dependencies and the package path in `dependencies`.

## Notes

From the cleanup side findings
(`.claude/notes/2026-10-04-cleanup-exploration.md:358`).

## Logs

- 2026-10-11: Заведено при сканировании заметок.
- 2026-10-11: Сделано: `Core` добавлен в `dependencies` и в продукты таргета
  `Apps/WorkflowServer/Package.swift`.
