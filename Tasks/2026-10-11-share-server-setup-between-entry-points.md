---
type: task
status: open
---

# Share the common server setup between the two entry points

`Projects/workflow-server/workflow-server/App.swift` and
`Projects/workflow-server/workflow-server-testing/App.swift` both compute
`~/.workflows`, build `Config(certificatesDirectory: .../certs)`, create an
`AuthRegistry` and call `Logger.enable(.workflow)`, then diverge: production
loads `oauth_client.json` and the Google token provider, testing uses
`InMemoryWorkflowStorage` and `TestingWorkflows`. Move the shared part into
`WorkflowServer` (one function or a `Config` factory) and leave only the
differences in the targets: storage, workflow set, providers.

Do it together with
`2026-10-11-env-override-bypasses-oauth-redirect-uri`: that fix changes how
`Config` is built, in both entry points.

## Notes

A5 from the cleanup exploration
(`.claude/notes/2026-10-04-cleanup-exploration.md:52`). The duplication
already caused B19 (host, port and certificate path written twice). Cost of
the change: ~10 lines; cost of leaving it: every config change is made twice.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
