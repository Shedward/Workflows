# 2026-03-27: OAuth2 Auth System + Sheets batchUpdate Bug

## What was built

Full OAuth2 user-auth system replacing service account auth (service accounts can't write to personal Google Drive — no storage quota).

### New files

| File | Description |
|------|-------------|
| `Core/Core/Sources/Core/Keychain/KeychainStorage.swift` | Generic `struct KeychainStorage: Sendable` wrapping `kSecClassGenericPassword`. `read/write/delete`. Write uses update-or-add pattern. |
| `Core/Rest/Sources/Rest/Authorizers/OAuthProvider.swift` | Universal `protocol OAuthProvider: Sendable` — `serviceID`, `displayName`, `isAuthorized() async -> Bool`, `authorizationURL() async throws -> URL`, `handleCallback(code:state:) async throws`. Lives next to `AccessTokenAuthorizer`. |
| `Services/GoogleServices/Sources/GoogleServices/Auth/GoogleOAuthCredentials.swift` | Loads GCP Desktop app JSON `{"installed": {"client_id", "client_secret", "auth_uri", "token_uri"}}`. Static `load(from: URL)`. |
| `Services/GoogleServices/Sources/GoogleServices/Auth/UserOAuthTokenProvider.swift` | Actor implementing `AccessTokenAuthorizer + OAuthProvider`. PKCE flow. Keychain for refresh token. |
| `Apps/WorkflowServer/Sources/WorkflowServer/Auth/AuthRegistry.swift` | `actor AuthRegistry` — `register`, `provider(for:)`, `allProviders`. |
| `Apps/WorkflowServer/Sources/WorkflowServer/Auth/AuthController.swift` | 3 GET routes: `/auth`, `/auth/:service`, `/auth/:service/callback`. |

### Modified files

| File | Change |
|------|--------|
| `Apps/WorkflowServer/Package.swift` | Added `Core/Rest` package + `Rest` product as dependency (needed for `OAuthProvider` import) |
| `Apps/WorkflowServer/Sources/WorkflowServer/App.swift` | Added `authRegistry: AuthRegistry` param, mounts `AuthController` |
| `Services/GoogleServices/.../GoogleDriveClient.swift` | `init(tokenProvider: any AccessTokenAuthorizer)` (was service-account-specific). Query param fix: `.query("supportsAllDrives", to: "true")` not in path string. |
| `Services/GoogleServices/.../GoogleSheetsClient.swift` | `init(tokenProvider: any AccessTokenAuthorizer)` (was service-account-specific) |
| `Projects/workflow-server/workflow-server/App.swift` | Bootstrap switched to `UserOAuthTokenProvider` + `AuthRegistry` |

### Key design decisions

- Server starts immediately — no blocking on auth
- Unauthorized service → `Failure("Google is not authorized. Visit /auth/google to authorize.")`
- `GET /auth/{service}` → JSON `{"url": "https://..."}` (not redirect) — client decides how to present
- Refresh token in macOS Keychain: service `"com.workflows.google"`, key `"refreshToken"`
- PKCE: `SecRandomCopyBytes` 32 bytes → base64url verifier; `CryptoKit.SHA256` → code_challenge
- `pendingVerifiers: [String: PendingVerifier]` dict with 10-min TTL, pruned on each `handleCallback` call
- Redirect URI: `http://localhost:8080/auth/google/callback` (GCP Desktop app type, no redirect URI needed in console)
- `nonisolated let serviceID` and `displayName` on `UserOAuthTokenProvider` (actor properties accessed from outside)

### Key bug fix: Drive query param

`URL.append(path:)` percent-encodes `?` to `%3F`. Never put query params in path strings.
Use `.query("supportsAllDrives", to: "true")` on the `Request` instead.

---

## HHWorkflows: Декомпозиция_портфеля

Workflow that automates portfolio decomposition table creation in Google Sheets.

### Structure

```
Декомпозиция_портфеля (parent)
  └─ onStart: Создать_таблицу_для_декомпозиции.to(.нужно_заполнить_таблицу)  ← subflow
  └─ on(.нужно_заполнить_таблицу): Таблица_заполнена.to(.нужно_провести_декомпозицию)
  └─ always: Завершить.toFinish()

Создать_таблицу_для_декомпозиции (child subflow, chainedAfterStart)
  1. Скопировать_шаблон_таблицы_для_декомпозиции  → copies Drive template, @Output spreadsheetId
  2. Заполнить_поля_таблицы_декомпозиции           → fills A1=portfolioKey, B14="Mob", B15="iOS"
```

### Constants (in copy action)

- Template spreadsheet ID: `1V4VFXKHZSLltv_zYcD7i8WDMWPbVHrBvkkFM-3ZBx3M`
- Destination folder ID: `1vlcteIRUy76mePEg6aPCreayTobmZpeg`

### Data flow

Parent starts subflow with its own `WorkflowData` (which contains `portfolioKey`).
Copy action reads `portfolioKey` → writes `spreadsheetId`.
Fill action reads both `portfolioKey` and `spreadsheetId`.

---

## OPEN BUG: Sheets batchUpdate returns 400

### Symptom

Child workflow reaches state `шаблон_скопирован` (copy succeeds), then:
```
"userDescription": "Failed to run action Заполнить_поля_таблицы_декомпозиции
 ↪ Validating response
 ↪ Wrong status code: 400"
```

Direct API test (curl or separate code) with the same spreadsheetId + same request body → 200 OK.

### What has been ruled out

- `EmptyBody.init(data:)` — ignores response data, no issue
- `WorkflowData` String round-trip — JSON encode/decode of String is correct
- `portfolioKey` bad value — copy action used it successfully (file was named correctly in Drive)
- Google Sheets API being disabled — user enabled it, drive copy works

### Current hypothesis: URL colon encoding

`GoogleSheetsClient` uses path `/v4/spreadsheets/\(spreadsheetId)/values:batchUpdate`.
`NetworkRestClient` builds URL via `url.append(path: path)`.

**Suspicion:** `url.append(path:)` may percent-encode the `:` in `values:batchUpdate` → `values%3AbatchUpdate`, causing Google to return 400 (not 404) because the method-style path doesn't match.

**Evidence for:** The "direct test" that succeeded may have used `curl` (which constructs the URL as a raw string), not the Swift client.

**Evidence against:** RFC 3986 allows `:` in non-first path segments; Apple's `append(path:)` should be correct.

### Next debugging steps

1. **Add URL to error log** in `NetworkRestClient.fetch` — log `urlRequest.url?.absoluteString` in the error handler to see the actual URL being sent.

2. **Or**: Change `NetworkRestClient` to build the URL as a string instead of `append(path:)`:
   ```swift
   url = URL(string: url.absoluteString + path) ?? url
   ```
   This avoids any encoding ambiguity.

3. **Check server logs**: The error handler already logs the full response body from Google — check `oslog` / Console.app for the Google error JSON which will say exactly what's wrong.

4. **Check WorkflowData in debugger**: Verify `spreadsheetId` read by fill action has no extra chars.

### Sheets client code for reference

```swift
// GoogleSheetsClient.batchUpdateValues
let request = Request<BatchUpdateBody, EmptyBody>(
    .post,
    "/v4/spreadsheets/\(spreadsheetId)/values:batchUpdate",
    body: body
)
_ = try await rest.fetch(request)
```

Expected request body:
```json
{
  "valueInputOption": "USER_ENTERED",
  "data": [
    {"range": "A1", "values": [["PORTFOLIO-TEST-00"]]},
    {"range": "B14", "values": [["Mob"]]},
    {"range": "B15", "values": [["iOS"]]}
  ]
}
```

---

## GCP Setup (done by user, for reference)

- OAuth client type: **Desktop app** (no redirect URI field — it's implicit)
- Scopes: `drive`, `spreadsheets`
- Consent screen: published (not Testing — Testing mode tokens expire in 7 days)
- Google Drive API: enabled
- Google Sheets API: enabled
- Credentials JSON at: `~/.workflows/google_cloud/oauth_client.json`

---

## Lessons learned this session

1. **`url.append(path:)` percent-encodes `?`** — always use `.query()` on `Request` for query params, never embed in path string
2. **Service accounts cannot create files in personal Google Drive** — no storage quota; OAuth user auth is required
3. **`AuthController` routing**: use single string `"auth/:service"` not variadic `"auth", ":service"`
4. **Actor properties accessed from outside** must be `nonisolated` (e.g. `serviceID`, `displayName`)
5. **`OAuthProvider` protocol** needs `import Foundation` for `URL` type

---

## Session 2 (continued same day): Bug diagnosis + branch review

### What was fixed

#### Sheets batchUpdate 400 — root cause found and fixed

Root cause: **`Content-Type: application/json` was never set** on POST requests in `NetworkRestClient`.

Google Sheets API treats the request body as a query parameter when Content-Type is missing, resulting in:
```
"Invalid JSON payload received. Unknown name {entire JSON body}... Cannot bind query parameter."
```

**Fix in `Core/Rest/Sources/Rest/Client/NetworkRestClient.swift`:**
```swift
let bodyData = try request.body.data()
urlRequest.httpBody = bodyData
if bodyData != nil && urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
}
```

Also improved error logging — response body now printed in error path.

#### URL construction changed

`url.append(path: path)` replaced with:
```swift
url = URL(string: url.absoluteString + path) ?? url
```
Avoids any ambiguity about whether `:` in `values:batchUpdate` gets encoded.

#### Network logger enabled

Added `Logger.enable(.network)` to `Projects/workflow-server/workflow-server/App.swift`. Without this, oslog network traces were silently discarded.

**Key oslog diagnostic command:**
```bash
/usr/bin/log stream --predicate 'subsystem == "me.shedward.workflows"' --level debug
```
Logs go to oslog, NOT stdout. Must use `log stream` or Console.app to see them.

#### WorkflowData initial data format

`POST /workflowInstances` requires JSON-encoded string values inside a `data` wrapper:
```json
{
  "workflowId": "Декомпозиция_портфеля",
  "initialData": {
    "data": {
      "portfolioKey": "\"PORTFOLIO-TEST-00\""
    }
  }
}
```
The outer `"data"` key maps to `WorkflowData`'s internal dict. All values are JSON-encoded strings (double-quoted inside the JSON string).

### Branch review findings (3 agents)

Three parallel agents reviewed the diff vs `main`. Key findings:

#### Critical (correctness)
- **No HTTP status check on token endpoints** — Google returns `{"error": "invalid_grant"}` with HTTP 400; current code tries to decode it as `TokenResponse` and gives a useless "Failed to decode" error. Should check status, decode `ErrorResponse`, and surface Google's message.
- **Force-unwrap** on `credentials.authURI` in `buildAuthURL` (UserOAuthTokenProvider line 187).
- **Hardcoded redirect URI** `http://localhost:8080/auth/google/callback` inside `GoogleServices` — couples the service library to the server's port. Should be a constructor parameter.

#### High (duplication)
- `base64url` encoding implemented twice: `Data.base64URLEncoded()` extension in `UserOAuthTokenProvider` and `base64url(_ data: Data)` method in `ServiceAccountTokenProvider`. Extract to shared `OAuthHelpers.swift`.
- `formEncode`/`percentEncode` instance methods in `UserOAuthTokenProvider` not shared with `ServiceAccountTokenProvider` (which uses an inline string). Unify.

#### Medium (cleanup)
- `KeychainStorage`: base query dict `[kSecClass, kSecAttrService, kSecAttrAccount]` built 3× in `read`, `write`, `delete`. Extract private `baseQuery(key:)`.
- `AuthController`: provider lookup guard duplicated in `authorizationURL` and `handleCallback`. Extract `requireProvider(context:)`.

### Pending fixes (planned, not yet implemented)

Plan written to `/Users/v.maltsev/.claude/plans/binary-booping-tide.md`. Commit order:
1. `KeychainStorage` — `baseQuery` helper
2. `OAuthHelpers.swift` — extract `base64URLEncoded` + `formEncode`
3. `UserOAuthTokenProvider` — fix force-unwrap, make `redirectURI` a param
4. Both providers — add HTTP status check + `ErrorResponse` parsing
5. `AuthController` — `requireProvider` helper
6. Bootstrap — pass `redirectURI` explicitly

---

## Session 3 (same day): Architecture refactors + Api DSL + skill creation

### What was done

All branch review fixes from Session 2 were implemented and committed. Then three architectural improvements were made:

#### 1. Content-Type moved to body types (commit `33cb448`)

**Problem:** `NetworkRestClient` hardcoded `"application/json"` for every request with a body — wrong for non-JSON body types, and wrong for GET requests.

**Solution:** Added `var contentType: String?` to `DataEncodable` protocol (default `nil`). Each body type self-declares:
- `JSONEncodableBody` → `"application/json"`
- `PlainTextBody` → `"text/plain; charset=utf-8"`
- `URLEncodedBody` → `"application/x-www-form-urlencoded"`

`NetworkRestClient` reads `request.body.contentType` — sets the header only if non-nil and not already set. No service-level configuration needed.

Also added `Bool: QueryConvertible` (needed for Drive/Sheets boolean query params).

#### 2. RSA key parsing replaced with `SecItemImport` (commit `378b4ac`)

**Problem:** `ServiceAccountTokenProvider` had ~65 lines of manual PKCS#8 DER parsing + ASN.1 offset arithmetic — fragile and opaque.

**Solution:** `SecItemImport(pemData, nil, &format, &type, [], nil, nil, &outItems)` handles PEM → `SecKey` natively. Pass `nil` for `importKeychain` to avoid storing in Keychain.

**Key:** `nil` keychain parameter = parse only, no storage. `SecExternalFormat.formatPEMSequence` + `SecExternalItemType.itemTypePrivateKey` guide format inference.

#### 3. Api DSL applied to Google clients (commits `70d1c82`, `5f9ca00`)

New files following the `ListRepositoriesForAuthenticatedUser` pattern:

| File | Description |
|------|-------------|
| `Drive/GoogleDriveApi.swift` | `public protocol GoogleDriveApi: Api {}` |
| `Drive/Api/CopyFile.swift` | Full endpoint: all documented params, Modifiers, Defaultable, docs link |
| `Drive/Models/DriveFile.swift` | Response model |
| `Sheets/GoogleSheetsApi.swift` | `public protocol GoogleSheetsApi: Api {}` |
| `Sheets/Api/BatchUpdateValues.swift` | Full endpoint with nested enums for render options |

Both `GoogleDriveClient` and `GoogleSheetsClient` now store `private let rest: RestClient` (not `NetworkRestClient`) and expose a generic `fetch<A: ServiceApi>` method.

**Swift 6 discovery:** Associated type witnesses in `public protocol Api` must be `public`. If `RequestBody` is not `EmptyBody`, you must declare `public typealias RequestBody = BodyType` AND the body struct must be `public`. Private/internal body structs cause Swift 6 to fall back to the default `EmptyBody` silently, producing a type mismatch error at the `Request(...)` call site.

`RestClient` needed `: Sendable` conformance for storage in `Sendable` classes.

### Architecture documentation

Created `Documentation/Architecture.md` covering:
- REST body types + `contentType` ownership
- Request composition + Query builder syntax
- `NetworkRestClient` URL construction rules
- Api DSL pattern + endpoint file conventions (one file per endpoint, docs link, all params, Modifiers, Defaultable)
- Core syntax utilities (Modifiers, Defaultable, DictionarySemantic)
- Auth system
- GoogleServices clients

Linked from `CLAUDE.md`.

### End-to-end test

Ran `POST /workflowInstances` with `workflowId: Декомпозиция_портфеля`, `initialData.data.portfolioKey: '"TEST-2026"'` → created instance. Then `takeTransition` with `Создать_таблицу_для_декомпозиции` → workflow reached `нужно_заполнить_таблицу`. Drive file was copied and Sheets batchUpdate succeeded end-to-end.

**initialData format reminder:**
```json
{
  "workflowId": "...",
  "initialData": {
    "data": {
      "key": "\"value\""
    }
  }
}
```
The `data` wrapper is required (maps to `WorkflowData`'s internal dict). All values are JSON-encoded strings.

### Claude Code skill created

`.claude/skills/gen-api-endpoint/SKILL.md` — generates a complete Swift Api DSL endpoint file.

Usage: `/gen-api-endpoint <description> [docs-url]`

Example: `/gen-api-endpoint Create Jira issue https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-issues/#api-rest-api-3-issue-post`

The skill:
1. Fetches the docs URL (if provided) for authoritative parameter list
2. Checks if a `ServiceApi` protocol already exists for the target service
3. Generates a complete endpoint file: all params, `///` doc comments, `Modifiers`, `Defaultable`, nested enums with `Sendable`, body struct as `public` with explicit `typealias`
4. Notes what `Models/ResponseType.swift` needs if a response model is required
5. Shows the `ServiceApi.swift` protocol file if the service is new

### Lessons learned this session

1. **Swift 6 associated type witnesses must be `public`** — if `protocol Api` is `public` and your `RequestBody` typealias points to a non-public struct, Swift silently uses the default `EmptyBody` instead of erroring at the typealias site. Error appears at `Request(... body: MyBody())` as a type mismatch.
2. **`RestClient` must be `Sendable`** — storing `any RestClient` in a `Sendable` class requires `public protocol RestClient: Sendable`.
3. **`SecItemImport` replaces manual PKCS#8 parsing** — pass `nil` for `importKeychain`, provide `&format` and `&type`, get back `[SecKey]`. No Keychain storage, no manual DER offset arithmetic.
4. **Content-Type belongs on the body type** — `NetworkRestClient` should not know the MIME type; it reads `body.contentType` instead.
5. **Claude Code skills** are loaded at session start from `.claude/skills/<name>/SKILL.md`. Newly created skills require a session restart to be invocable via `/skill-name`.
