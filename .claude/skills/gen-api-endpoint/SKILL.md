---
name: gen-api-endpoint
description: Generate a type-safe Swift API endpoint file for this codebase. Accepts an endpoint description and optional URL to official docs. Produces a complete endpoint file matching the project's Api DSL pattern.
argument-hint: "<EndpointName> [docs-url]"
allowed-tools: WebFetch, Read, Write, Glob, Grep, Bash
---

Generate a Swift API endpoint file for this project following the established Api DSL pattern.

## Input

Arguments: `$ARGUMENTS`

Parse this as:
- First token that starts with `http` — the documentation URL to fetch
- Remaining text — description of the endpoint to generate (what it does, what service it's for)

If a documentation URL is provided, fetch it first with WebFetch and use the parameter list from the docs as the authoritative source for all properties.

## Your task

1. **Identify the service** from the description (e.g. Jira, GitHub, Google Drive, Slack…)
2. **Check if a service `Api` protocol already exists** — grep `Services/` for `protocol.*Api` to find existing ones (e.g. `GithubApi`, `GoogleDriveApi`)
3. **Fetch the docs** if a URL was provided — extract every query parameter, body field, path parameter, and their types/descriptions
4. **Generate the endpoint file** strictly following the rules below
5. **Print the full file content** so the user can review it, then ask where to save it

## Endpoint file rules

Follow these rules exactly. The reference implementation is at:
`Services/Github/Sources/Github/Api/Repositories/ListRepositoriesForAuthenticatedUser.swift`

Full pattern from `Documentation/Architecture.md`:

```
// LineOne: URL to official API documentation
// https://api.example.com/docs/endpoint

import Core
import Rest

/// One-line description copied from official docs.
public struct EndpointName: ServiceApi {
    public typealias RequestBody = RequestBodyType   // only if not EmptyBody
    public typealias ResponseBody = ResponseType     // only if not EmptyBody

    // 1. Required path parameters — non-optional var
    public var resourceId: String

    // 2. Body parameters — optional var with doc comments
    /// Description from docs.
    public var name: String?

    // 3. Query parameters — optional var with doc comments
    /// Description from docs.
    public var filter: String?

    public var request: RouteRequest {
        Request(.post, "/path/\(resourceId)", body: RequestBodyType(name: name))
            .query(
                .set("filter", to: filter)
            )
    }

    public init(
        resourceId: String,
        name: String? = nil,
        filter: String? = nil
    ) {
        self.resourceId = resourceId
        self.name = name
        self.filter = filter
    }
}

extension EndpointName: Defaultable {
    public init() { self.init(resourceId: "") }
}

extension EndpointName: Modifiers {
    public func name(_ name: String) -> Self    { with { $0.name = name } }
    public func filter(_ value: String) -> Self { with { $0.filter = value } }
}

extension EndpointName {
    public enum SomeType: String, Sendable, QueryConvertible {
        case foo = "FOO"
        case bar = "BAR"
    }
}

// MARK: - Request body

public struct RequestBodyType: JSONEncodableBody {
    let name: String?
}
```

## Key rules

1. **ALL documented parameters** — include every query param and body field from the official docs. Mark each with a `///` doc comment copied from the docs. Even params you don't use yet.
2. **All `var`, all optional** — except required path params which are non-optional.
3. **`init` with all params and `= nil` defaults** — callers can use either init or Modifier builders.
4. **`Defaultable`** — always required. Empty init uses empty string for required path params.
5. **`Modifiers`** — one `func` per settable property, using `with { $0.prop = value }`.
6. **Nested enums** go in a separate `extension EndpointName { }` block at the bottom, with `: String, Sendable` conformance. Add `QueryConvertible` if used as query param.
7. **Body struct** at the very bottom, `public struct`, `JSONEncodableBody`. Only if there is a request body.
8. **Response model** — if the endpoint returns a response object, note that a separate file in `Models/` is needed, and show what its struct would look like (but don't generate the file automatically).
9. **Doc comment on the struct** — one-line from the official docs.
10. **First line of file** — URL to official docs as a `//` comment.
11. **`public typealias RequestBody`** — required when body is not `EmptyBody` (Swift 6 associated type visibility rule — body struct must also be `public`).
12. **`Sendable`** on all enums used as stored properties.
13. **GET requests** — use `Request(.get, "/path")` with no `body:` argument; `RequestBody` is `EmptyBody` by default, no typealias needed.
14. **Auth** — add `.authorised(true)` on the request if the endpoint requires authentication.

## Body type reference

| Situation | Body type |
|-----------|-----------|
| JSON request body | `JSONEncodableBody` (custom struct) |
| JSON response | `JSONDecodableBody` (custom struct) |
| No request body (GET) | omit — `EmptyBody` is the default |
| Plain text body | `PlainTextBody` |

## After generating

- Show the complete file
- Tell the user what file path to save it to (matching the service's `Api/` directory convention)
- If a response model is needed, describe what `Models/ResponseType.swift` should contain
- If no `ServiceApi` protocol exists yet for this service, show the 2-line protocol file that needs to be created first
