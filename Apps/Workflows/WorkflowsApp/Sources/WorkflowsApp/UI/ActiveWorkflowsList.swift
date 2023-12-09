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
    private var listViewModel: LoadingListViewModel<AnyWorkflow>?

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
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
        navigationPath.append(Navigations.NewWorkflowsList())
    }
}

#Preview {
    ActiveWorkflowsList(navigationPath: .constant(.init()))
        .frame(width: 300)
}
