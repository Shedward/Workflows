---
type: task
status: open
effort: medium
impact: high
---

# Run the Google OAuth flow and one Drive/Sheets call against the real endpoints

No real Google call has ever been made from this project:
`~/.workflows/google_cloud/oauth_client.json` does not exist on this machine,
so the production server does not start here. Put a real client file in
place, go through `GET /auth/google` → consent → `/auth/google/callback`,
then run one workflow step that calls Drive or Sheets, and record the
outcome in a note.

First thing to settle: `GoogleOAuthCredentials.load` reads the `installed`
key (GCP "Desktop app" client), while the bring-up note assumes a "Web
application" client with `https://127.0.0.1:8443/auth/google/callback`
registered. Not verified: Google is believed to accept only `http://127.0.0.1:<any port>`
loopback redirects for installed clients, which would make the current
`https` callback fail for either client type. Pick the client type, fix the
loader or the redirect accordingly.

Needs the user: creating the client in GCP Console, placing the file,
clicking consent in the browser. The agent prepares the server and reads the
logs.

## Notes

Open since `.claude/notes/2026-04-24-prod-server-bringup.md:74,97`.
Sources: `Services/GoogleServices/.../GoogleOAuthCredentials.swift`
(`RawFile.installed`), `Projects/workflow-server/workflow-server/App.swift`
(`redirectURI: AuthController.callbackURL(service: "google", on: config)`).
Unblocks `2026-10-11-oauth-token-provider-through-rest-client`.

## Changelog

- Заведено при сканировании заметок 2026-10-11.
- Оценено effort medium (нужны пользователь и GCP-консоль, код готов),
  impact high (прод с Google ни разу не работал).
