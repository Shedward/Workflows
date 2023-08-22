//
//  AppDelegate.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import SwiftUI
import os
import Prelude
import GoogleCloud

public final class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var logger = Logger(scope: .global)

    public func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.enabledScopes.append(.network)
        logger.notice("Application did finish launching")
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        Task {
            do {
                try await Dependencies.shared.googleAuthorizer.processRedirectUrl(url)
            } catch {
                logger.fault("Failed to process redirect: \(error, privacy: .public)")
            }
        }
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        true
    }
}
