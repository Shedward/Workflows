//
//  workflow_appApp.swift
//  workflow-app
//
//  Created by Мальцев Владислав on 02.04.2026.
//

import SwiftUI
import WorkflowApp

@main
struct App: SwiftUI.App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WorkflowApp.App().body
    }
}
