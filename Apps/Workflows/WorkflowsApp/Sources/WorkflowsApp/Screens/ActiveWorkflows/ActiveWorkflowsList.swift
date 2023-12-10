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
    
    @Environment(\.dependencies)
    private var dependencies: AllDependencies

    let navigation: Navigation
    
    @SwiftUI.State
    private var listViewModel: LoadingListViewModel<AnyWorkflow>?
    
    var body: some View {
        LoadingList(viewModel: listViewModel) { (item: AnyWorkflow) in
            WorkflowCell(details: item.details)
                .listRowSeparator(.hidden)
        } empty: {
            ContentUnavailableView {
                Label("No Workflows", systemImage: "sparkles")
            } actions: {
                Button("Create") {
                    createWorkflow()
                }
            }
        }
        .contentInsets(bottom: 32)
        .listStyle(.plain)
        .overlay(alignment: .bottom) {
            BottomToolbar {
                Button {
                    createWorkflow()
                } label: {
                    Label("Start new", systemImage: "plus")
                }
                Button {
                    listViewModel?.reload()
                } label: {
                    Label("Reload", systemImage: "arrow.triangle.2.circlepath")
                }
                Spacer()
                Button {
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
        }
        .navigationTitle("Workflows")
        .task {
            listViewModel = LoadingListViewModel {
                try await dependencies.workflowsStorage.workflows()
            }
            await listViewModel?.reload()
        }
    }
    
    private func createWorkflow() {
        navigation.showNewWorkflows()
    }
}

#Preview {
    ActiveWorkflowsList(navigation: Navigation())
        .frame(width: 300)
}
