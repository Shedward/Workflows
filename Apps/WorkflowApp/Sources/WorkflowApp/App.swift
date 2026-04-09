//
//  App.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 20.04.2026.
//

import AppKit
import Carbon.HIToolbox
import SwiftUI

public struct App: SwiftUI.App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    public var body: some Scene {
        MenuBarExtra("Workflows", systemImage: "bolt.horizontal.circle") {
            TrayMenu()
        }
        .menuBarExtraStyle(.menu)
    }

    public init() {}
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotkey: GlobalHotkey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        FocusPresenter.shared.install()

        hotkey = GlobalHotkey(
            keyCode: UInt32(kVK_Space),
            modifiers: UInt32(optionKey)
        ) {
            Task { @MainActor in
                FocusPresenter.shared.toggle()
            }
        }
    }
}
