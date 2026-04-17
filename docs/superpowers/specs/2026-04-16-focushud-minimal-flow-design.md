# FocusHUD Minimal User Flow

## Context

FocusHUD is a lightweight floating overlay for interacting with workflows. It currently exists as a single-zone view with hardcoded mock content, no view model, and no API wiring. We need to build the foundational architecture (three-zone layout) and implement the first end-to-end user flow: starting a workflow from an empty state.

## Goal

Implement the minimal flow: **empty state → select a workflow → show running workflow card.** This exercises the full vertical stack — UI zones, view model, API — with the smallest useful scope.

## Architecture

### Three-Zone Layout

FocusHUD becomes a generic container with three vertical zones:

- **Roof** (top, optional) — ambient info: parent workflow, statuses, notifications. Empty for this iteration.
- **Content** (center, always visible) — current activity / main status. The focal point.
- **Drawer** (bottom, optional) — interactive UI: transition lists, input forms, workflow selection.

The HUD is anchored at roughly the upper third of the screen so the drawer has room to expand downward. Roof and drawer animate in/out. Content is always present. The glass effect and floating shadow wrap the entire composite.

```swift
struct FocusHUD<Roof: View, Content: View, Drawer: View>: View {
    @ViewBuilder var roof: () -> Roof
    @ViewBuilder var content: () -> Content
    @ViewBuilder var drawer: () -> Drawer
}
```

FocusHUD knows nothing about what's inside its zones. It handles layout, animation, glass effect, keyboard focus, ESC-to-hide, and drag-to-move.

### FocusViewModel

An `@Observable` class that holds data state and drives the UI.

```swift
@Observable
@MainActor
final class FocusViewModel {
    enum State {
        case empty
        case selectingWorkflow([Workflow])
        case active(WorkflowInstance)
    }

    private(set) var state: State = .empty
    private let service: WorkflowsService

    func startSelection() async { ... }    // GET /workflows → .selectingWorkflow
    func select(workflow: Workflow) async { ... }  // POST /workflowInstances → .active
}
```

Takes `WorkflowsService` as an injected dependency (not from SwiftUI environment) for testability.

### Assembly Point

Where FocusHUD is instantiated, state is mapped to concrete views:

- **Content:** `.empty` / `.selectingWorkflow` → `EmptyFocus`, `.active(instance)` → `WorkflowCard(instance)`
- **Drawer:** `.selectingWorkflow(workflows)` → `WorkflowList(workflows)`, otherwise hidden
- **Roof:** `EmptyView()` (unused this iteration)

This assembly lives in a new coordinating view (e.g. `FocusRoot`) that owns the view model and passes concrete views into FocusHUD. FocusPresenter hosts `FocusRoot` instead of `FocusHUD` directly.

### User Flow

1. App launches → FocusHUD shows content with `EmptyFocus` ("Start" button)
2. User taps Start → `viewModel.startSelection()` fetches workflows → state becomes `.selectingWorkflow`
3. Drawer animates in with `WorkflowList` showing available workflows
4. User selects a workflow → `viewModel.select(workflow:)` calls `POST /workflowInstances` → state becomes `.active(instance)`
5. Drawer animates out, content transitions from `EmptyFocus` to `WorkflowCard`

### Error Handling

For this minimal iteration: if an API call fails, stay in the current state. No error UI yet — just don't transition. We can add error display in the drawer later.

## Files to Modify

| File | Change |
|------|--------|
| `UI/Focus/FocusHUD.swift` | Restructure to three-zone generic container with animated roof/drawer |
| `UI/Focus/FocusViewModel.swift` | Implement `@Observable` state machine with API calls |
| `UI/EmptyFocus.swift` | Add action callback for the Start button |
| `Services/Workflows/WorkflowsService.swift` | Add `startWorkflow(id:)` method |
| `UI/Tray/FocusPresenter.swift` | Host `FocusRoot` instead of `FocusHUD` directly |

## New Files

| File | Purpose |
|------|---------|
| `UI/Focus/FocusRoot.swift` | Assembly view: owns FocusViewModel, maps state → zone views |
| `UI/Focus/WorkflowList.swift` | Drawer content: list of workflows to start |

## Existing Code to Reuse

- `WorkflowCard` (`UI/WorkflowCard.swift`) — no changes needed
- `Card` component (`UI/DesignSystem/Components/Card.swift`) — for WorkflowList row styling
- `EmptyFocus` (`UI/EmptyFocus.swift`) — extend with action callback
- `WorkflowsService` (`Services/Workflows/WorkflowsService.swift`) — extend with startWorkflow
- `StartWorkflow` endpoint (`Domain/API/.../StartWorkflow.swift`) — already exists
- `GetWorkflows` endpoint (`Domain/API/.../GetWorkflows.swift`) — already exists
- Theme modifiers, `PreferableTint`, `floatingShadow`, `movable` — all reused as-is

## Verification

1. Build the app with `./Tools/Run/build`
2. Start the workflow server with `./Tools/Run/run_server`
3. Launch WorkflowApp, press Option+Space to show FocusHUD
4. Verify empty state shows "Start" button
5. Press/click Start — drawer should appear with workflow list fetched from server
6. Select a workflow — drawer should close, content should show WorkflowCard with workflow name and state
7. Press ESC — HUD should hide
8. Press Option+Space — HUD should reappear showing the active workflow card (state persists)
