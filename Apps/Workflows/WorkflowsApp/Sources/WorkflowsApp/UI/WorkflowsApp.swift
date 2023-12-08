//
//  WorkflowsApp.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import SwiftUI
import UI

public struct WorkflowsApp: App {

    public init() {
    }

    public var body: some Scene {
        MenuBarExtra {
            ActiveWorkflowsList()
                .frame(width: 300, height: 400)
                .spacing(.s0)
                .backgroundColor(\.background.primary)
        } label: {
            HStack {
                Image(systemName: "flowchart")
                Text("WF")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
