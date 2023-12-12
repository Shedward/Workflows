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
    
    let navigation: Navigation
    
    @SwiftUI.State
    private var workflows: Loading<[AnyNewWorkflow], Error> = .loading
    
    var body: some View {
        let listViewModel = LoadingListViewModel {
            try await dependencies.newWorkflowsService.workflows().flatMap { try $0.workflows.get() }
        }
        LoadingList(viewModel: listViewModel) { (item: AnyNewWorkflow) in
            Button {
                createWorkflow(item)
            } label: {
                NewWorkflowCell(description: item.description)
            }
            .buttonStyle(.plain)
        } empty: {
            ContentUnavailableView {
                Label("No Possible Workflows", systemImage: "sparkles")
            }
        }
        .navigationTitle("Create workflow")
    }
    
    private func createWorkflow(_ item: AnyNewWorkflow) {
        Task {
            _ = try await item.createWorkflow()
            navigation.popToRoot()
        }
    }
}

#Preview {
    NewWorkflowList(navigation: Navigation())
        .frame(width: 300, height: 300)
}
