# Architecture & Code Style Guide

Reference for Claude sessions working on this codebase. Covers the REST framework, API endpoint DSL, core syntax utilities, and auth system.

---

## Core/Rest — REST client framework

### Body types

All request and response bodies conform to `DataEncodable` / `DataDecodable` from `Core/Rest/Sources/Rest/Body/DataCodable.swift`.

| Type | `contentType` | Notes |
|------|---------------|-------|
| `JSONEncodableBody` | `application/json` | Conform your struct + `Encodable` |
| `JSONDecodableBody` | — | Conform your struct + `Decodable` |
| `JSONBody` | `application/json` | Codable (both encode + decode) |
| `PlainTextBody` | `text/plain; charset=utf-8` | String body |
| `UrlEncodedBody` | `application/x-www-form-urlencoded` | Form body |
| `EmptyBody` | `nil` | No body; used for GETs or when response is ignored |
| `ListBody<T>` | `application/json` | JSON array encode/decode |

`NetworkRestClient` sets the `Content-Type` header automatically from `body.contentType`. Do **not** set it in service clients via decorators.

### Request composition

`Request<RequestBody, ResponseBody>` is fully composable:

```swift
Request(.post, "/some/path", body: myBody)
    .query(.set("key", to: value).set("other", to: other))
    .header("X-Custom", to: "value")
    .authorised(true)    // marks request as needing auth token
```

For GET requests with no body use the `Defaultable` init:
```swift
Request(.get, "/some/path")   // RequestBody inferred as EmptyBody
```

### Query builder

`Query` supports a builder style via `DictionarySemantic` + `Modifiers`:

```swift
// Single key
.query("key", to: value)

// Multiple keys — preferred style matching GitHub/Google endpoints
.query(
    .set("key1", to: value1)
    .set("key2", to: value2)
)
```

`Query.set` is a static method (from `DictionarySemantic`). Values must be `QueryConvertible`. Supported types: `String`, `Int`, `Bool`, `Array<QueryConvertible>`, `Optional<QueryConvertible>`, any `RawRepresentable` where `RawValue: QueryConvertible`.

### NetworkRestClient

Avoid `url.append(path:)` — it may percent-encode `:` in method-style paths like `values:batchUpdate`. URL construction uses string concatenation:

```swift
url = URL(string: url.absoluteString + path) ?? url
```

This is intentional. Do not revert.

### Auth decorators

`RequestDecoratorsSet` chains decorators. Two common ones:

```swift
RequestDecoratorsSet()
    .addHeaders(myHeaders)        // AddHeadersRequestDecorator — static headers
    .authorizer(tokenProvider)    // AccessTokenDecorator — Bearer token from AccessTokenAuthorizer
```

`AccessTokenDecorator` only adds the token if `request.metadata[NeedAuthorizedMetadataKey]` is `true` (default). Override with `.authorised(false)` on a request to skip auth.

---

## Api DSL — defining REST endpoints

The preferred way to define any REST endpoint is as a struct conforming to a service-specific `Api` protocol.

### Protocol chain

```
Api (Core/Rest)
  └── GithubApi (Services/Github)
  └── GoogleDriveApi (Services/GoogleServices)
  └── GoogleSheetsApi (Services/GoogleServices)
```

Each service protocol adds nothing — it's just a marker for type safety.

### Endpoint file structure

**One file per endpoint.** See `Services/Github/Sources/Github/Api/Repositories/ListRepositoriesForAuthenticatedUser.swift` as the canonical reference.

```
// LineOne: URL to official API documentation
// https://api.example.com/docs/endpoint

import Core
import Rest

/// One-line description from the official docs.
public struct EndpointName: ServiceApi {
    // 1. Path parameters (required, non-optional)
    public var resourceId: String

    // 2. Body parameters (optional with = nil defaults)
    public var name: String?
    public var type: EndpointType?

    // 3. Query parameters (optional with = nil defaults)
    public var filter: String?
    public var includeAll: Bool?

    public var request: RouteRequest {
        Request(.post, "/path/\(resourceId)", body: RequestBody(name: name, type: type?.rawValue))
            .query(
                .set("filter",     to: filter)
                .set("includeAll", to: includeAll)
            )
    }

    public init(
        resourceId: String,
        name: String? = nil,
        type: EndpointType? = nil,
        filter: String? = nil,
        includeAll: Bool? = nil
    ) {
        self.resourceId = resourceId
        self.name = name
        // ... assign all
    }
}

extension EndpointName: Defaultable {
    public init() { self.init(resourceId: "") }
}

extension EndpointName: Modifiers {
    public func name(_ name: String) -> Self    { with { $0.name = name } }
    public func type(_ type: EndpointType) -> Self { with { $0.type = type } }
    public func filter(_ value: String) -> Self { with { $0.filter = value } }
    public func includeAll(_ value: Bool) -> Self { with { $0.includeAll = value } }
}

extension EndpointName {
    public enum EndpointType: String {
        case foo = "FOO"
        case bar = "BAR"
    }
}

// MARK: - Request body (private to this file)

private struct RequestBody: JSONEncodableBody {
    let name: String?
    let type: String?
}
```

### Rules

1. **All documented parameters** — include every query param and body field from the official docs, even ones not currently used. Mark with doc comments.
2. **All `var`, all optional** except required path params.
3. **`init` with all params and `= nil` defaults** — callers can use either init or Modifiers builders.
4. **`Defaultable`** — required for use with `DictionarySemantic` static builders.
5. **`Modifiers`** — one method per settable property.
6. **Nested enums** in `extension EndpointName {}` block (not inside the struct).
7. **Private body structs** at the bottom of the file.
8. **Response models** in a separate `Models/` directory, not inside the endpoint file.

### Client pattern

Clients are generic dispatchers — they do not contain request logic:

```swift
public final class ExampleClient: Sendable {
    private let rest: RestClient

    public init(tokenProvider: any AccessTokenAuthorizer) {
        self.rest = NetworkRestClient(
            endpoint: ...,
            requestDecorators: RequestDecoratorsSet().authorizer(tokenProvider)
        )
    }

    public func fetch<A: ExampleApi>(_ api: A) async throws -> A.ResponseBody {
        try await rest.fetch(api)
    }
}
```

`RestClient` already has `fetch<A: Api>` via the extension in `Core/Rest/Sources/Rest/Api/RestClient+Api.swift`.

---

## Core syntax utilities

### `Modifiers`

Builder pattern. Provides `with { $0.prop = value } -> Self`. Conforming types get value-semantics mutation for free.

```swift
extension MyStruct: Modifiers {
    public func name(_ name: String) -> Self { with { $0.name = name } }
}

// Usage:
let updated = original.name("new").otherProp(42)
```

### `Defaultable`

Types that have a meaningful "zero" or "empty" state. Required for `DictionarySemantic`'s static `set` initialiser.

```swift
extension MyStruct: Defaultable {
    public init() { self.init(id: "") }
}
```

### `DictionarySemantic`

Provides `subscript`, `set(_:to:)` instance method, and — when combined with `Defaultable` — a static `set` factory. Used by `Query` and `Headers`.

```swift
// Creates a Query with one key, chains more
let q: Query = .set("a", to: "1").set("b", to: "2")
```

The `Value` type must match exactly. For `Query`, `Value = QueryConvertible`. Optional values are supported via `Optional: QueryConvertible`.

### `ArraySemantic`

Provides `appending` builder. Used by `RequestDecoratorsSet`:

```swift
RequestDecoratorsSet().appending(MyDecorator())
// or via convenience:
RequestDecoratorsSet().addHeaders(headers).authorizer(provider)
```

---

## Auth system

### `AccessTokenAuthorizer`

Protocol for anything that can produce a `Bearer` or other token header:

```swift
public protocol AccessTokenAuthorizer: Sendable {
    func authorizationHeaders() async throws -> Headers
}
```

Use `.authorizer(provider)` on `RequestDecoratorsSet` to wire it in.

### `OAuthProvider`

Protocol for services that expose a 3-legged OAuth flow:

```swift
public protocol OAuthProvider: Sendable {
    var serviceID: String { get }
    var displayName: String { get }
    func isAuthorized() async -> Bool
    func authorizationURL() async throws -> URL
    func handleCallback(code: String, state: String) async throws
}
```

`serviceID` and `displayName` must be `nonisolated` on actors.

### `UserOAuthTokenProvider`

Google 3-legged OAuth actor. Key points:
- Takes `redirectURI: String` at `init` — **not hardcoded**; pass from the bootstrap
- Stores refresh token in macOS Keychain (`com.workflows.google` / `refreshToken`)
- PKCE: 32-byte random verifier, SHA256 challenge
- `authorizationHeaders()` throws `"Google is not authorized. Visit /auth/google to authorize."` if no valid token

```swift
UserOAuthTokenProvider(
    credentials: oauthCredentials,
    scopes: ["https://www.googleapis.com/auth/drive", ...],
    redirectURI: "http://localhost:8080/auth/google/callback"
)
```

### `ServiceAccountTokenProvider`

Google service account JWT bearer actor. Key points:
- Loads PEM key via `SecItemImport` — handles PKCS#8 natively, no manual DER parsing
- Signs with `SecKeyCreateSignature(.rsaSignatureMessagePKCS1v15SHA256)`
- **Cannot access personal Google Drive** — no storage quota; use `UserOAuthTokenProvider` for Drive

### `AuthRegistry` + `AuthController`

`AuthRegistry` (actor) holds providers by `serviceID`.
`AuthController` exposes `/auth`, `/auth/:service`, `/auth/:service/callback`.

Bootstrap:
```swift
let authRegistry = AuthRegistry()
authRegistry.register(googleProvider)
// Mount AuthController(registry: authRegistry) in App.swift
```

---

## GoogleServices clients

### Drive

- **Client**: `GoogleDriveClient` — `fetch<A: GoogleDriveApi>`
- **Base URL**: `https://www.googleapis.com`
- **Endpoints**: `Services/GoogleServices/Sources/GoogleServices/Drive/Api/`
- **Models**: `Services/GoogleServices/Sources/GoogleServices/Drive/Models/`
- **Protocol**: `GoogleDriveApi` (extends `Api`)

### Sheets

- **Client**: `GoogleSheetsClient` — `fetch<A: GoogleSheetsApi>`
- **Base URL**: `https://sheets.googleapis.com`
- **Endpoints**: `Services/GoogleServices/Sources/GoogleServices/Sheets/Api/`
- **Protocol**: `GoogleSheetsApi` (extends `Api`)

### Adding a new Google endpoint

1. Find the official docs URL
2. Create `ServiceName/Api/EndpointName.swift` following the endpoint file structure above
3. Add a response model to `ServiceName/Models/` if needed
4. Use `client.fetch(EndpointName(requiredId: "...").optionalParam(value))` at the call site
