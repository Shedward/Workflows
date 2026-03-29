# 2026-03-29 SwiftLint Integration

## What was done

### SwiftLint Xcode integration
- Created `Tools/Run/swiftlint` run script for Xcode Build Phase.
- Root cause of "swiftlint not found": Xcode's minimal PATH doesn't include `/opt/homebrew/bin`.
- Fix: script prepends `/opt/homebrew/bin:/usr/local/bin` to PATH before calling `swiftlint`.

### `.swiftlint.yml` config
- Created project-root `.swiftlint.yml` with ~67 opt-in rules adopted from ios-apps project (general rules only, no UIKit/iOS specifics).
- Key settings: `line_length: {warning: 150, error: 200}`, `identifier_name` allows `_` and excludes short names (`id`, `to`, `x`, `y`, `z`), `disabled_rules: [shorthand_argument]`.
- `single_line_function` custom rule added to enforce multi-line function bodies.

### Cyrillic identifiers in HHWorkflows
- `allowed_symbols` in `type_name`/`identifier_name` does not support Unicode/Cyrillic characters (tried 66 letters, didn't work).
- Solution: nested `Workflows/HHWorkflows/.swiftlint.yml` that disables `type_name` and `identifier_name` entirely for that module.

### Fixed all 156 violations
Three-pass approach:
1. `swiftlint --fix` — resolved ~80% (trailing_comma, colon spacing, etc.)
2. Config changes — policy decisions (allow `_`, raise line_length, etc.)
3. Manual fixes — semantic renames, type_contents_order reordering across ~29 files

### `prefer_key_path` autocorrect regression
- `swiftlint --fix` incorrectly changed `flatMap { $0.queryValue }` → `map(\.queryValue)` inside `extension Optional`.
- `map` on `Optional<Wrapped>` where `queryValue: String?` gives `String??`, not `String?`. Build error.
- Fix: `Core/Rest/Sources/Rest/Syntax/QueryConvertible.swift` — changed back to `flatMap(\.queryValue)`.

### `full_check` build failure detection
- Bug: `xcodebuild ... | grep -v "^$" || XCODE_STATUS="${PIPESTATUS[0]}"` was always showing success because `|| true` resets PIPESTATUS.
- Fix: capture with `|| XCODE_STATUS="${PIPESTATUS[0]}"` before the reset, then check `${XCODE_STATUS:-0}`.

### `GoogleOAuthCredentials.loadDefault()` removal
- `loadDefault()` hardcoded `.workflows/google_cloud/oauth_client.json` path inside the service layer.
- Removed the method entirely. App.swift already constructed the URL. Path knowledge now lives only at the app layer.
- Also unnested `Entry` struct from `RawFile` to fix SwiftLint nesting violation.

## Remaining work
- None from this session.
