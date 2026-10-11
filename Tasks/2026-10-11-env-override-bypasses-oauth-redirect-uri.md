---
type: bug
status: open
---

# Environment override of host/port leaves the OAuth redirect URI on the default address

`App.main` reads `http.hostname` / `http.port` from `EnvironmentVariablesProvider`
(process environment, then `.env`) before the `InMemoryProvider` filled from
`Config`, so Hummingbird can bind to an address that `Config` never saw. The
OAuth redirect URI is built from `Config.baseURL` (`AuthController.callbackURL(service:on:)`),
so with `HTTP_PORT=9000` the server listens on 9000 and sends Google back to
`https://127.0.0.1:8443/auth/google/callback`.

Expected: the redirect URI follows the address the server actually binds to,
whatever provider supplied it.

## Notes

Remainder of B19 from the 2026-10 cleanup: the duplication of host, port and
route was removed in `c22b537` (`Config.baseURL`, `AuthController.callbackURL`),
the provider-order part was left open. Candidate fix: build `Config` from the
`ConfigReader` once, after all providers, and hand that `Config` to both the
server and `AuthController`.

## Changelog

- Заведено из «Bug backlog» B19 в `.claude/notes/2026-10-04-cleanup-exploration.md`
  при переносе беклога в `Tasks/`.
