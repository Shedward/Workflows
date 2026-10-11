---
type: bug
status: open
---

# An answer that lacks an expected `@Ask` field fails as an internal error, not as an invalid request

`BindAskInputs.ask(for:at:)` throws a plain `Failure("Ask input \(key) is not
provided")` when the submitted answer has no value for a declared `@Ask` key.
`Failure` carries no client-facing `ErrorKind`, so the server maps it to the
`internal` group (HTTP 500) and the text is the engine's wording, not a
message the caller can act on. The caller's mistake belongs to the
`invalidRequest` group (400), like the other client errors (CONTEXT.md rule:
four semantic groups).

Repro: start a workflow with an `Asking` transition, answer it with a body
missing one of `expectedFields`; observe the status and `userDescription`.
HTTP status not verified by experiment, read from `ErrorResponseMiddleware`.

Expected: a dedicated error type with `kind: .invalidRequest`, a
`userDescription` naming the missing field, and an integration test.

## Notes

Known since the Ask design note (`.claude/notes/2026-04-04-branching-and-ask.md:87`,
"no server-side check that the answer contains all expected fields"). Pattern
to follow: the error types introduced for B16 (`Semantic HTTP statuses for
client mistakes`).

## Changelog

- Заведено при сканировании заметок 2026-10-11.
