//
//  App.swift
//  WorkflowApp
//
//  Created by Vlad Maltsev on 20.04.2026.
//

import SwiftUI

public struct App: SwiftUI.App {
    let config: Config

    public var body: some Scene {
        WindowGroup {
            MainScreen()
                .environment(\.workflowService, config.workflowsService)
        }
    }

    public init() {
        self.config = .debug
    }
}
