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
            SpacedVStack {
                ForEach(0..<2) { _ in
                    WorkflowCell(
                        key: "MOB-22623",
                        icon: Image(systemName: "briefcase"), 
                        statusIcon: nil,
                        name: "Реализовать экран списка окна",
                        state: "В работе"
                    )
                }
                .spacing(.d1)

                SpacedVStack {
                    ForEach(0..<2) { _ in
                        WorkflowCell(
                            key: "MOB-22623",
                            icon: Image(systemName: "briefcase"),
                            statusIcon: nil,
                            name: "Реализовать экран списка окна",
                            state: "В работе"
                        )
                    }
                }
                .spacedFrame(\.background.tertiary)
                .spacing(.d2)
            }
            .spacing(.s0)
            .spacedPadding()
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
