//
//  OAuthHelperMain.swift
//  OAuthHelper
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI
import OAuthHelperApp
import os

@main 
struct OAuthHelperMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Window("OAuthHelper", id: "OAuthHelperApp") {
            OAuthHelperApp()
        }
        .handlesExternalEvents(matching: ["*"])
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
        }
    }
}
