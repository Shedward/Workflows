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
                List {
                    Section("В работу") {
                        WorkflowCell(
                            key: "PORTFOLIO-22623", 
                            icon: Image(systemName: "briefcase"),
                            name: "Реализовать экран списка флоу",
                            state: "В работе"
                        )
                        WorkflowCell(
                            key: "PORTFOLIO-22623",
                            icon: Image(systemName: "briefcase"),
                            name: "Реализовать экран списка флоу",
                            state: "АБ-тестирование"
                        )
                    }
                    Section("Ждем") {
                        WorkflowCell(
                            key: "MOB-22321",
                            icon: Image(systemName: "eyes"),
                            name: "Реализовать экран списка флоу",
                            state: "Ревью"
                        )
                    }
                }
                .listStyle(.plain)
                .frame(maxWidth: 300)
                .padding()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        } label: {
            HStack {
                Image(systemName: "flowchart")
                Text("WF")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
