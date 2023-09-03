//
//  WorkflowsApp.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import SwiftUI

public struct WorkflowsApp: App {

    public init() {
    }

    public var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading) {
                Text("Workflows")
                    .font(.title)
                Text("Here will be all your work")
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        } label: {
            HStack {
                Image(systemName: "flowchart")
                Text("WF")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
