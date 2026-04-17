# FocusHUD Minimal User Flow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the empty → select workflow → show running workflow card flow in FocusHUD.

**Architecture:** FocusHUD becomes a generic three-zone container (roof/content/drawer). A `FocusViewModel` holds data state and drives API calls. A `FocusRoot` assembly view maps state to concrete views in each zone.

**Tech Stack:** SwiftUI, Swift Observation (`@Observable`), macOS 26 glass effects, existing REST client + API endpoints.

**Spec:** `docs/superpowers/specs/2026-04-16-focushud-minimal-flow-design.md`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `Domain/API/Sources/API/WorkflowsInstances/StartWorkflow.swift` | Modify | Add public init |
| `Apps/WorkflowApp/Sources/WorkflowApp/Services/Workflows/WorkflowsService.swift` | Modify | Add `startWorkflow(id:)` |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusViewModel.swift` | Rewrite | State machine + API calls |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusHUD.swift` | Rewrite | Three-zone generic container |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/EmptyFocus.swift` | Modify | Add `onStart` action callback |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/WorkflowList.swift` | Create | Drawer view for workflow selection |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusRoot.swift` | Create | Assembly: maps state → zone views |
| `Apps/WorkflowApp/Sources/WorkflowApp/UI/Tray/FocusPresenter.swift` | Modify | Host FocusRoot instead of FocusHUD |
| `Apps/WorkflowApp/Sources/WorkflowApp/Testing/Mocks/Workflow+Mocks.swift` | Create | Preview mock data |

---

### Task 1: Add public init to StartWorkflow

`StartWorkflow` has internal properties and no public init, so it can't be used from WorkflowApp module.

**Files:**
- Modify: `Domain/API/Sources/API/WorkflowsInstances/StartWorkflow.swift`

- [ ] **Step 1: Add public init**

Replace the full file content with:

```swift
//
//  StartWorkflow.swift
//  API
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import Rest

public struct StartWorkflow: WorkflowApi {
    public typealias ResponseBody = WorkflowInstance

    public static let method = Method.post
    public static let path = "/workflowInstances"

    public let workflowId: String
    public let initialData: WorkflowData?

    public init(workflowId: String, initialData: WorkflowData? = nil) {
        self.workflowId = workflowId
        self.initialData = initialData
    }

    public var request: RouteRequest {
        request(body: RequestBody(workflowId: workflowId, initialData: initialData))
    }
}

extension StartWorkflow {
    public struct RequestBody: JSONBody {
        public let workflowId: String
        public let initialData: WorkflowData?
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add Domain/API/Sources/API/WorkflowsInstances/StartWorkflow.swift
git commit -m "feat: add public init to StartWorkflow endpoint"
```

---

### Task 2: Add startWorkflow to WorkflowsService

**Files:**
- Modify: `Apps/WorkflowApp/Sources/WorkflowApp/Services/Workflows/WorkflowsService.swift`

- [ ] **Step 1: Add the method**

Add after the existing `getWorkflows()` method (after line 27):

```swift
    func startWorkflow(id: String) async throws -> WorkflowInstance {
        let request = StartWorkflow(workflowId: id)
        return try await rest.fetch(request)
    }
```

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/Services/Workflows/WorkflowsService.swift
git commit -m "feat: add startWorkflow to WorkflowsService"
```

---

### Task 3: Implement FocusViewModel

**Files:**
- Rewrite: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusViewModel.swift`

- [ ] **Step 1: Write FocusViewModel**

Replace the full file content:

```swift
//
//  FocusViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

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

    init(service: WorkflowsService) {
        self.service = service
    }

    func startSelection() {
        Task {
            do {
                let workflows = try await service.getWorkflows()
                withAnimation(.snappy) {
                    state = .selectingWorkflow(workflows)
                }
            } catch {
                // Minimal iteration: stay in current state on failure
            }
        }
    }

    func select(workflow: Workflow) {
        Task {
            do {
                let instance = try await service.startWorkflow(id: workflow.id)
                withAnimation(.snappy) {
                    state = .active(instance)
                }
            } catch {
                // Minimal iteration: stay in current state on failure
            }
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusViewModel.swift
git commit -m "feat: implement FocusViewModel state machine"
```

---

### Task 4: Restructure FocusHUD to three-zone container

**Files:**
- Rewrite: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusHUD.swift`

- [ ] **Step 1: Rewrite FocusHUD as generic three-zone container**

Replace the full file content:

```swift
//
//  FocusHUD.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import SwiftUI

struct FocusHUD<Roof: View, Content: View, Drawer: View>: View {
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool
    @State private var tint: Color?

    @ViewBuilder var roof: Roof
    @ViewBuilder var content: Content
    @ViewBuilder var drawer: Drawer

    var body: some View {
        ZStack(alignment: .center) {
            let shape = RoundedRectangle(cornerSize: CGSize(width: 24, height: 24))
            VStack(spacing: theme.spacing.m) {
                roof
                content
                drawer
            }
            .onPreferableTintChange { tint = $0 }
            .padding()
            .glassEffect(.clear.tint((tint ?? .clear).opacity(0.10)), in: shape)
            .floatingShadow(in: shape)
            .transition(.blurReplace)
            .focusable()
            .focusEffectDisabled()
            .focused($isFocused)
            .onAppear { isFocused = true }
            .onKeyPress(.escape) {
                FocusPresenter.shared.hide()
                return .handled
            }
            .fixedSize()
            .movable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Content only") {
    FocusHUD {
        EmptyView()
    } content: {
        WorkflowCard(workflowInstance: .Mock.decomposition)
    } drawer: {
        EmptyView()
    }
}

#Preview("Empty state") {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusHUD.swift
git commit -m "feat: restructure FocusHUD to three-zone generic container"
```

---

### Task 5: Update EmptyFocus with action callback

**Files:**
- Modify: `Apps/WorkflowApp/Sources/WorkflowApp/UI/EmptyFocus.swift`

- [ ] **Step 1: Add onStart callback and make it a button**

Replace the full file content:

```swift
//
//  EmptyFocus.swift
//  WorkflowApp
//

import SwiftUI

struct EmptyFocus: View {
    var onStart: () -> Void

    var body: some View {
        Button(action: onStart) {
            Label("Start", systemImage: "play")
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        EmptyView()
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/EmptyFocus.swift
git commit -m "feat: add onStart action callback to EmptyFocus"
```

---

### Task 6: Create WorkflowList drawer view + Workflow mocks

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/WorkflowList.swift`
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/Testing/Mocks/Workflow+Mocks.swift`

- [ ] **Step 1: Create Workflow mocks for previews**

Create `Apps/WorkflowApp/Sources/WorkflowApp/Testing/Mocks/Workflow+Mocks.swift`:

```swift
//
//  Workflow+Mocks.swift
//  WorkflowApp
//

import API

extension Workflow {
    enum Mock {
        static let all: [Workflow] = [
            Workflow(id: "Декомпозиция_портфеля", stateId: [], transitions: []),
            Workflow(id: "Код_ревью", stateId: [], transitions: []),
            Workflow(id: "Дейли_стендап", stateId: [], transitions: []),
        ]
    }
}
```

- [ ] **Step 2: Create WorkflowList view**

Create `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/WorkflowList.swift`:

```swift
//
//  WorkflowList.swift
//  WorkflowApp
//

import API
import SwiftUI

struct WorkflowList: View {
    let workflows: [Workflow]
    let onSelect: (Workflow) -> Void

    @Environment(\.theme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.s) {
            ForEach(workflows) { workflow in
                Button {
                    onSelect(workflow)
                } label: {
                    Card {
                        Text(workflow.id)
                            .themeFont(\.body)
                            .themeColor(\.content.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    FocusHUD {
        EmptyView()
    } content: {
        EmptyFocus {}
    } drawer: {
        WorkflowList(workflows: Workflow.Mock.all) { _ in }
    }
}
```

- [ ] **Step 3: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 4: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/Testing/Mocks/Workflow+Mocks.swift \
        Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/WorkflowList.swift
git commit -m "feat: add WorkflowList drawer view and Workflow mocks"
```

---

### Task 7: Create FocusRoot assembly view

This is the coordination layer that maps FocusViewModel state to concrete views in FocusHUD zones.

**Files:**
- Create: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusRoot.swift`

- [ ] **Step 1: Create FocusRoot**

Create `Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusRoot.swift`:

```swift
//
//  FocusRoot.swift
//  WorkflowApp
//

import SwiftUI

struct FocusRoot: View {
    @State var viewModel: FocusViewModel

    var body: some View {
        FocusHUD {
            EmptyView()
        } content: {
            switch viewModel.state {
            case .empty, .selectingWorkflow:
                EmptyFocus(onStart: viewModel.startSelection)
            case .active(let instance):
                WorkflowCard(workflowInstance: instance)
            }
        } drawer: {
            if case .selectingWorkflow(let workflows) = viewModel.state {
                WorkflowList(workflows: workflows) { workflow in
                    viewModel.select(workflow: workflow)
                }
            }
        }
    }
}
```

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/Focus/FocusRoot.swift
git commit -m "feat: add FocusRoot assembly view"
```

---

### Task 8: Wire up FocusPresenter to host FocusRoot

**Files:**
- Modify: `Apps/WorkflowApp/Sources/WorkflowApp/UI/Tray/FocusPresenter.swift`
- Modify: `Apps/WorkflowApp/Sources/WorkflowApp/Services/Config/Config.swift`

- [ ] **Step 1: Update FocusPresenter.install()**

In `FocusPresenter.swift`, replace line 31:

```swift
let hosting = NSHostingController(rootView: FocusHUD())
```

with:

```swift
let viewModel = FocusViewModel(service: Config.debug.workflowsService)
let hosting = NSHostingController(rootView: FocusRoot(viewModel: viewModel))
```

Add the import at the top of the file if not already present — `Config` and `FocusRoot` are in the same module so no import needed.

- [ ] **Step 2: Build to verify**

Run: `./Tools/Run/build`

- [ ] **Step 3: Commit**

```bash
git add Apps/WorkflowApp/Sources/WorkflowApp/UI/Tray/FocusPresenter.swift
git commit -m "feat: wire FocusPresenter to host FocusRoot with view model"
```

---

### Task 9: End-to-end verification

- [ ] **Step 1: Start the workflow server**

```bash
./Tools/Run/run_server
```

- [ ] **Step 2: Build and launch the app**

```bash
./Tools/Run/build
```

Then launch WorkflowApp from Xcode or the build output.

- [ ] **Step 3: Manual test the flow**

1. Press **Option+Space** — FocusHUD appears with "Start" button
2. Click **Start** — drawer animates in showing available workflows from server
3. Click a workflow — drawer closes, content shows WorkflowCard with workflow name and current state
4. Press **ESC** — HUD hides
5. Press **Option+Space** again — HUD reappears showing the active workflow card (state persists)

- [ ] **Step 4: Verify previews**

Open the following files in Xcode and check that SwiftUI previews render:
- `FocusHUD.swift` — "Content only" and "Empty state" previews
- `EmptyFocus.swift` — preview with FocusHUD wrapper
- `WorkflowList.swift` — preview showing mock workflows in drawer
