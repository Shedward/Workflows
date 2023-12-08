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
    
    @SwiftUI.State
    private var workflows: Loading<[AnyWorkflow], Error> = .loading
    
    var body: some View {
        Group {
            switch workflows {
            case .loading:
                LoadingView()
            case .loaded(let value):
                if value.isEmpty {
                    ContentUnavailableView {
                        Label("No Workflows", systemImage: "sparkles")
                    } actions: {
                        Button("Create") {
                            createWorkflow()
                        }
                    }
                } else {
                    List {
                        ForEach(value) { workflow in
                            WorkflowCell(details: workflow.details)
                        }
                    }
                }
            case .failure(let error):
                FailureView(error)
            }
        }
        .task { await reload() }
        .refreshable { await reload() }
    }
    
    private func reload() async {
        await _workflows.assignAsync {
            try await dependencies.workflowsStorage.workflows()
        }
    }
    
    private func createWorkflow() {
        
    }
}

#Preview {
    ActiveWorkflowsList()
        .frame(width: 300)
}
