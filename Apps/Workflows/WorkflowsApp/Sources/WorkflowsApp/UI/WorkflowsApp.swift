//
//  WorkflowsApp.swift
//
//
//  Created by v.maltsev on 03.09.2023.
//

import SwiftUI
import UI

@Observable
public class WorkflowsAppViewModel {
    var navigation = NavigationPath()
}

public struct WorkflowsApp: App {
    
    static let size = CGSize(width: 300, height: 400)

    @Bindable
    private var viewModel: WorkflowsAppViewModel

    public init() {
        viewModel = WorkflowsAppViewModel()
    }

    public var body: some Scene {
        MenuBarExtra {
            NavigationStack(path: $viewModel.navigation) {
                ActiveWorkflowsList(navigationPath: $viewModel.navigation)
                    .navigationDestination(for: Navigations.NewWorkflowsList.self) { _ in
                        NewWorkflowList(navigationPath: $viewModel.navigation)
                    }
            }
            .frame(width: WorkflowsApp.size.width, height: WorkflowsApp.size.height)
            .spacing(.s0)
            .backgroundColor(\.background.primary)
        } label: {
            Image(systemName: "flowchart")
        }
        .menuBarExtraStyle(.window)
    }
}
