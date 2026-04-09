//
//  FocusPresenter.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

import AppKit
import SwiftUI

/// Owns the Spotlight-style focus HUD panel and centralises show/hide/toggle so
/// the global hotkey and tray menu share a single code path.
///
/// The HUD is hosted in a custom `NSPanel` rather than a SwiftUI `Window`
/// scene because plain SwiftUI windows return `NO` from `canBecomeKeyWindow`,
/// which prevents `onKeyPress` from firing.
@MainActor
@Observable
final class FocusPresenter {
    static let shared = FocusPresenter()

    private(set) var isVisible = false

    @ObservationIgnored private var panel: FocusPanel?
    @ObservationIgnored private var visibilityObserver: NSKeyValueObservation?

    private init() {}

    /// Builds the panel. Call once at launch.
    func install() {
        let hosting = NSHostingController(rootView: FocusHUD())

        let panel = FocusPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 80),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hosting
        // Re-assert the size: assigning `contentViewController` resizes the
        // panel to the controller's view, which is 0×0 before SwiftUI lays
        // out. NB: do NOT use `sizingOptions = [.preferredContentSize]` —
        // it triggers an infinite `windowDidLayout`/resize loop in NSPanel.
        panel.setContentSize(NSSize(width: 320, height: 80))

        panel.initialFirstResponder = hosting.view
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.hidesOnDeactivate = true
        panel.isMovableByWindowBackground = true
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        // Restoration can leave the panel off-screen or in a "hidden" state
        // that no-ops `makeKeyAndOrderFront` on subsequent shows.
        panel.isRestorable = false

        // Mirror real panel visibility into the observable property so the
        // tray label stays in sync however the panel was hidden. The KVO
        // closure is `Sendable`, so it can't touch main-actor state directly.
        visibilityObserver = panel.observe(\.isVisible, options: [.initial, .new]) { _, _ in
            Task { @MainActor in
                FocusPresenter.shared.refreshVisibility()
            }
        }

        self.panel = panel
    }

    func show() {
        guard let panel else { return }
        centerOnActiveScreen(panel)
        // An `.accessory` app whose previous window was hidden via
        // `hidesOnDeactivate` will silently no-op `makeKeyAndOrderFront`
        // unless the app is reactivated first.
        NSApp.activate()
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func toggle() {
        // Read the panel directly: the cached `isVisible` lags by one
        // main-actor hop behind the KVO callback.
        if panel?.isVisible == true {
            hide()
        } else {
            show()
        }
    }

    fileprivate func refreshVisibility() {
        isVisible = panel?.isVisible ?? false
    }

    private func centerOnActiveScreen(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return }
        let size = panel.frame.size
        let origin = NSPoint(
            x: visible.midX - size.width / 2,
            y: visible.midY - size.height / 2
        )
        panel.setFrameOrigin(origin)
    }
}

/// `NSPanel` subclass that overrides `canBecomeKey` so the borderless HUD can
/// receive keyboard events.
private final class FocusPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
