---
type: task
status: open
effort: high
impact: high
---

# Migrate persisted instances when a workflow changes

On startup `Workflows.run()` resumes the instances on disk; one whose workflow
is not registered or whose `version` differs is skipped with a warning and
stays in `~/.workflows/instances/` until deleted by hand, and taking a
transition on it fails with `WorkflowVersionMismatch`. Every bump of a
workflow's `version` strands its running instances.

Wanted: a real migration mechanism, so that a workflow can declare how
instances of an older version become instances of the current one, and
startup applies it instead of skipping. Pieces to design:

- what a migration is (a function from old `WorkflowData` + state to new, or
  a per-version chain `1 → 2 → 3`);
- where it is declared (next to `version` on the workflow);
- what happens to instances that have no migration path (quarantine
  directory with the reason, listed by the app, never silently dropped);
- how the engine tests it (fixtures with an old-version instance file).

## Notes

B1 follow-up: the skip-and-log behaviour was chosen on 2026-10-10 as option 1
with "migrations come later" (`.claude/notes/2026-10-04-cleanup-exploration.md:119,126`;
CONTEXT.md "механизм миграций ожидается позже"). The dry run over a copy of
the real directory had 144 files: 92 finished evicted, 52 orphans of testing
workflows skipped and still listed as running, so the quarantine part has a
real case today.

Sources: `Workflows.run()`, `WorkflowRunner.resume()`,
`WorkflowsError.WorkflowVersionMismatch`, `JSONFileWorkflowStorage`.

## Logs

- 2026-10-11: Заведено при сканировании заметок; выбран полный механизм, а
  не только карантин, потому что идея давно назрела и будет сделана.
- 2026-10-11: Оценено effort high (отдельная сессия с дизайном механизма),
  impact high (каждый bump версии теряет инстансы, 52 сироты уже лежат).
