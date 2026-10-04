# 2026-10-04 — Upgrade to Xcode 27 / Swift 6.4

Branch: `upgrade-to-xcode27`. Toolchain: Xcode 27.0 (27A266a), Swift 6.4, macOS 27.2.

## Why the build broke

1. Pinned `swift-async-algorithms` 1.1.1 (transitive, via hummingbird) fails Swift 6.4 region isolation:
   `returning 'result' as a 'sending' result risks causing data races` in
   `MultiProducerSingleConsumerAsyncChannel+Internal.swift`. Fixed upstream; 1.1.7 compiles.
2. After updating pins, `swift-subprocess` API changed: `CollectedResult` was replaced by the
   noncopyable `ExecutionResult<ClosureResult, Output, Error>`.

## What changed

- `Services/Git/Package.swift`: `swift-subprocess` `from: "0.3.0"` → `from: "1.0.0"`.
- `Domain/WorkflowEngine/Package.swift`: `swift-syntax` `from: "602.0.0"` → `from: "604.0.0"` (matches Swift 6.4).
- `Services/Git/Sources/Git/Client/GitClient.swift`: returns `ExecutionResult<Void, Output, Error>`.
  Error wrapping is inlined (`do/catch` → `Failure`) because `Failure.wrap<Result>` can't carry a `~Copyable` result.
- All other dependencies moved forward via the (gitignored) workspace `Package.resolved`, no manifest changes:
  hummingbird 2.19.0 → 2.27.0, swift-configuration 1.0.0 → 1.2.1, swift-nio 2.92.1 → 2.103.0,
  swift-crypto 4.2.0 → 5.0.0, swift-collections 1.3.0 → 1.7.1, swift-log 1.8.0 → 1.15.1, etc.

## Verification

- Builds clean, no project warnings: `workflow-server-testing`, `workflow-server`, `workflow-app`,
  plus `Github`, `HHWorkflows`, `GoogleServices` schemes.
- `swift test --package-path Core/Core`: 3/3 pass.
- Integration: 25/25 scripts in `Tools/Tests/run_all` pass, run against the testing server with a
  throwaway self-signed cert (`CFFIXED_USER_HOME` sandbox + `CURL_CA_BUNDLE`), because of the cert issue below.
- `swiftlint` clean on `Services/Git`.

## Gotchas found (not caused by the upgrade)

- **TLS certs missing on this machine.** Both servers load `~/.workflows/certs/localhost+2.pem` and
  `localhost+2-key.pem` (mkcert naming). The directory doesn't exist, `mkcert` isn't installed, and no mkcert
  root CA is in the keychain, so `./Tools/Run/full_check` dies with `NIOSSLError.failedToLoadCertificate`.
  Fix: `brew install mkcert && mkcert -install && mkdir -p ~/.workflows/certs && cd ~/.workflows/certs && mkcert localhost 127.0.0.1 ::1`.
- **`workflow-server` (production) fails strict validation at startup**: `HHWorkflows` need `googleDrive` /
  `googleSheets` dependencies that `Projects/workflow-server/workflow-server/App.swift` never registers, and
  `Работать_над_портфелем` has graph errors. Pre-existing WIP.
- **Updating pins while Xcode is open**: a running Xcode restores a deleted `Package.resolved` within ~2.5s
  from its in-memory state, so `xcodebuild -resolvePackageDependencies` keeps the old pins. Workaround used:
  resolve in a scratch SwiftPM package with the same remote constraints and copy its `Package.resolved` into
  `Workflow.xcworkspace/xcshareddata/swiftpm/`. Also clear `.build/DerivedData/SourcePackages` when a package
  changes its trait set between versions (stale `SubprocessSpan` trait error from swift-subprocess 0.3 → 0.5+).
- CLAUDE.md still says integration tests need a server on `:8080`; scripts actually use `https://127.0.0.1:8443`.

## Remaining

- Changes are uncommitted on `upgrade-to-xcode27`.
- In the Xcode app: File → Packages → Reset Package Caches (or restart Xcode) so it picks up the new pins.
