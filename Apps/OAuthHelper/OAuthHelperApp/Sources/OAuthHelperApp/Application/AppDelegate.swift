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
        logger.notice("Application did finish launching")
    }

    public func application(_ application: NSApplication, open urls: [URL]) {
        logger.notice("Application open urls \(urls, privacy: .public)")
    }
}
