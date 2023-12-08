//
//  NewWorkflowList.swift
//
//
//  Created by Vlad Maltsev on 08.12.2023.
//

import SwiftUI
import Prelude
import Workflow
import UI

struct NewWorkflowList: View {
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies
    
    @Binding
    var navigationPath: NavigationPath
    
    @SwiftUI.State
    private var workflows: Loading<[AnyNewWorkflow], Error> = .loading
    
    var body: some View {
        LoadingList { (item: AnyNewWorkflow) in
            Button {
                createWorkflow(item)
            } label: {
                NewWorkflowCell(newWorkflow: item)
            }
            .buttonStyle(.plain)
        } load: {
            try await dependencies.newWorkflowsService.workflows().flatMap { try $0.workflows.get() }
        } empty: {
            ContentUnavailableView {
                Label("No Possible Workflows", systemImage: "sparkles")
            }
        }
        .listStyle(.inset)
        .navigationTitle("Create workflow")
    }
    
    private func createWorkflow(_ item: AnyNewWorkflow) {
        Task {
            _ = try await item.createWorkflow()
            navigationPath.removeLast(navigationPath.count)
        }
    }
}

#Preview {
    NewWorkflowList(navigationPath: .constant(.init()))
        .frame(width: 300, height: 300)
}
