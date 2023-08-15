//
//  OAuthHelperMain.swift
//  OAuthHelper
//
//  Created by v.maltsev on 14.08.2023.
//

import SwiftUI
import OAuthHelperApp

@main 
struct OAuthHelperMain: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            OAuthHelperApp()
        }
    }
}
