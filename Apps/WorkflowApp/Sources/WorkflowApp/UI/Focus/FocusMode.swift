//
//  FocusMode.swift
//  WorkflowApp
//

import SwiftUI

enum FocusModeID: Hashable {
    case initial
    case switching
    case transition
}

@MainActor
protocol FocusMode {
    associatedtype Roof: View
    associatedtype Content: View
    associatedtype Drawer: View

    @ViewBuilder var roof: Roof { get }
    @ViewBuilder var content: Content { get }
    @ViewBuilder var drawer: Drawer { get }
}

@MainActor
struct AnyFocusMode {
    let roof: AnyView
    let content: AnyView
    let drawer: AnyView

    init<Mode: FocusMode>(_ mode: Mode) {
        self.roof = AnyView(mode.roof)
        self.content = AnyView(mode.content)
        self.drawer = AnyView(mode.drawer)
    }
}

struct ModeBarEntry {
    let icon: String
    let shortcut: KeyEquivalent
}

@MainActor
struct FocusModeDescriptor: Identifiable {
    let id: FocusModeID
    let bar: ModeBarEntry?
    let make: @MainActor (FocusViewModel) -> AnyFocusMode
}
