# 2026-03-29 Persistent Storage

## What was done

### Codable conformances
Made all engine types serializable to support JSON persistence:
- `TransitionID: Codable` (all String fields — synthesized)
- `WorkflowData: Codable` with custom `init(from:)`/`encode(to:)` using a single-value container to encode as flat `[String: String]` (avoids `{"data": {"data": {...}}}` nesting)
- `TransitionState+Codable.swift` — custom Codable for `TransitionState` and `TransitionState.State`; the `failed(Error)` case is serialized as `{type, userDescription, debugDescription}` and decoded as a `DeserializedError` struct that conforms to `DescriptiveError`
- `WorkflowInstance: Codable` (synthesized; all fields are now Codable)

### JSONFileWorkflowStorage
New actor `JSONFileWorkflowStorage` implementing `WorkflowStorage`:
- Stores one `{uuid}.json` per instance in a configurable directory (default `~/.workflows/instances/`)
- In-memory cache for all reads; only mutations touch disk
- Atomic writes via `Data.write(to:options:.atomic)` (OS-managed temp-rename, no explicit temp file)
- Expired finished instances are deleted via `FileManager.removeItem` (no full rewrite needed)
- Directory created on init if absent; missing files on load are silently skipped (corrupt file tolerance)
- JSON is pretty-printed and sorted for human readability
- Encoder/decoder configured with `.iso8601` date strategy

### Storage injection
`Workflows.init` now accepts `storage: WorkflowStorage = InMemoryWorkflowStorage()` as the first parameter. Existing callers that omit it keep working. The server (`Projects/workflow-server/App.swift`) passes `JSONFileWorkflowStorage(directory: workflowsConfigDir.appending(path: "instances"))`.

### Workflow version safety check
- Added `var version: WorkflowVersion { get }` to `AnyWorkflow` protocol (was only on `Workflow`)
- Added `workflowVersion: WorkflowVersion` field to `WorkflowInstance`; set from `workflow.version` at creation time in both storage implementations
- Added `WorkflowsError.WorkflowVersionMismatch` error with `instanceId`, `workflowId`, `instanceVersion`, `workflowVersion` fields
- `WorkflowRunner.resume()` checks version for each loaded instance before running automatic transitions — throws on mismatch
- `WorkflowRunner.takeTransition()` checks version before marking the instance as executing — throws on mismatch
- Migration mechanism is not yet implemented; mismatched instances must be deleted manually for now

## Decisions
- Per-instance files chosen over single-file array: each mutation only touches one file; corrupt file doesn't affect others; expired cleanup is a simple `rm`
- No backward-compatible Codable for `workflowVersion` — tool not yet in production use, clean slate preferred
- `swiftlint type_contents_order` requires `static func` before instance properties; moved `static func load` to the top of `JSONFileWorkflowStorage`

## Remaining work
- No migration mechanism for version mismatches — future work
- No retry mechanism for failed transitions
- No timeout for wait transitions
