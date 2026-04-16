//
//  FocusPresenter.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 09.04.2026.
//

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
    @ObservationIgnored private var screenObserver: NSObjectProtocol?

    private init() {}

    /// Builds the panel. Call once at launch.
    func install() {
        let viewModel = FocusViewModel(service: Config.debug.workflowsService)
        let hosting = NSHostingController(rootView: FocusRoot(viewModel: viewModel))

        let panel = FocusPanel(
            contentRect: NSRect(x: 0, y: 0, width: 100, height: 100),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.contentViewController = hosting

        panel.initialFirstResponder = hosting.view
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.hidesOnDeactivate = true
        panel.isMovableByWindowBackground = false
        panel.collectionBehavior = [.fullScreenAuxiliary, .transient, .moveToActiveSpace]
        // Restoration can leave the panel off-screen or in a "hidden" state
        // that no-ops `makeKeyAndOrderFront` on subsequent shows.
        panel.isRestorable = false

        // Mirror real panel visibility into the observable property so the
        // tray label stays in sync however the panel was hidden. The KVO
        // closure is `Sendable`, so it can't touch main-actor state directly.
        visibilityObserver = panel.observe(\.isVisible, options: [.initial, .new]) { _, _ in
            MainActor.assumeIsolated {
                FocusPresenter.shared.refreshVisibility()
            }
        }

        // Re-fit the panel to its new monitor whenever the system relocates it
        // (e.g. display reconfiguration). Manual dragging is disabled.
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeScreenNotification,
            object: panel,
            queue: .main
        ) { _ in
            MainActor.assumeIsolated {
                FocusPresenter.shared.fitToPanelScreen()
            }
        }

        self.panel = panel
    }

    func show() {
        guard let panel else { return }
        fitToActiveScreen(panel)
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

    fileprivate func fitToPanelScreen() {
        guard let panel, let frame = panel.screen?.visibleFrame else { return }
        panel.setFrame(frame, display: true)
    }

    private func fitToActiveScreen(_ panel: NSPanel) {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
        guard let frame = screen?.visibleFrame else { return }
        panel.setFrame(frame, display: true)
    }
}

/// `NSPanel` subclass that overrides `canBecomeKey` so the borderless HUD can
/// receive keyboard events.
private final class FocusPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
