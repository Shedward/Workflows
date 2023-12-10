//
//  WorkflowsApp.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import SwiftUI
import UI

public struct WorkflowsApp: App {
    
    static let size = CGSize(width: 300, height: 400)

    @Bindable
    private var navigation = Navigation()
    
    public init() {
    }

    public var body: some Scene {
        MenuBarExtra {
            NavigationStack(path: $navigation.path) {
                ActiveWorkflowsList(navigation: navigation)
                    .navigationDestination(for: Navigation.NewWorkflowsList.self) { _ in
                        NewWorkflowList(navigation: navigation)
                    }
            }
            .frame(width: WorkflowsApp.size.width, height: WorkflowsApp.size.height)
            .spacing(.s1)
            .backgroundColor(\.background.primary)
        } label: {
            Image(systemName: "flowchart")
        }
        .menuBarExtraStyle(.window)
    }
}
