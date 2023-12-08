//
//  ActiveWorkflowsList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude
import Workflow
import UI

struct ActiveWorkflowsList: View {
    
    @Binding
    var navigationPath: NavigationPath
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
    @SwiftUI.State
    private var workflows: Loading<[AnyWorkflow], Error> = .loading
    
    var body: some View {
        LoadingList { (item: AnyWorkflow) in
            WorkflowCell(details: item.details)
        } load: {
            try await dependencies.workflowsStorage.workflows()
        } empty: {
            ContentUnavailableView {
                Label("No Workflows", systemImage: "sparkles")
            } actions: {
                Button("Create") {
                    createWorkflow()
                }
            }
        }
        .navigationTitle("Workflows")
    }
    
    private func createWorkflow() {
        navigationPath.append(Navigations.NewWorkflowsList())
    }
}

#Preview {
    ActiveWorkflowsList(navigationPath: .constant(.init()))
        .frame(width: 300)
}
