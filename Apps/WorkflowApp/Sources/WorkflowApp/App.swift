//
//  App.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 20.04.2026.
//

import Carbon.HIToolbox
import SwiftUI

/// The executable's `@main` type must declare `@NSApplicationDelegateAdaptor(AppDelegate.self)` itself:
/// SwiftUI installs the delegate only from the `@main` type, and without it neither the HUD panel nor
/// the global hotkey is set up.
public struct App: SwiftUI.App {
    public var body: some Scene {
        MenuBarExtra("Workflows", systemImage: "bolt.horizontal.circle") {
            TrayMenu()
        }
        .menuBarExtraStyle(.menu)
    }

    public init() {}
}

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkey: GlobalHotkey?

    public func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        FocusPresenter.shared.install()

        hotkey = GlobalHotkey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey)
        ) {
            FocusPresenter.shared.toggle()
        }
    }
}
