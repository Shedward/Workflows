//
//  AppDelegate.swift
//
//
//  Created by v.maltsev on 15.08.2023.
//

import SwiftUI
import os
import Prelude

public final class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var logger = Logger(scope: .global)

    public func applicationDidFinishLaunching(_ notification: Notification) {
        Logger.enabledScopes.append(.network)
        logger.notice("Application did finish launching")
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        GoogleOAuthAuthorizer.shared.processRedirectUrl(url)
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        true
    }
}
