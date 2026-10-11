---
type: task
status: open
effort: medium
impact: low
depends-on: [2026-10-11-verify-live-google-oauth-flow]
---

# Route the Google token requests through the project's Rest client

`UserOAuthTokenProvider.refreshAccessToken` and `exchangeCodeForTokens`
build a `URLRequest` by hand (`urlRequest(tokenURI:body:)`), call
`URLSession.shared.data(for:)` and check the status in their own
`validateTokenResponse`. The project has `Core/Rest` for exactly this:
`Request<UrlEncodedBody, JSONBody<TokenResponse>>` sent through an injected
`RestClient`, with the status validator from the framework.

Expected: the provider takes a `RestClient`, the two token calls are `Request`
values, `validateTokenResponse` and `urlRequest` go away, and a unit test
with a fake client covers refresh and code exchange.

## Notes

Remainder of S7 (`.claude/notes/2026-10-04-cleanup-exploration.md:680`);
the other half, the unreferenced `ServiceAccountTokenProvider`, was deleted.
`UrlEncodedBody` was kept in the cleanup with the words "the Google token
exchange is the natural first user of the form body". Source:
`Services/GoogleServices/.../UserOAuthTokenProvider.swift`.

Blocked on a verified live flow: this is the only code that talks to Google
and it has never been exercised against the real endpoint, so a rewrite
cannot be checked without it.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
- Оценено effort medium (переписать на `Request` плюс тест с fake client),
  impact low (внутренняя консистентность).
