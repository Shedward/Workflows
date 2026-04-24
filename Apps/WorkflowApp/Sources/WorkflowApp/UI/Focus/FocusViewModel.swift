//
//  FocusViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class FocusViewModel {
    enum State {
        case empty
        case selectingWorkflow([Workflow])
        case active(WorkflowInstance)
        case failed(String)
    }

    private(set) var state: State = .empty

    private let service: WorkflowsService

    init(service: WorkflowsService) {
        self.service = service
    }

    func startSelection() {
        Task {
            do {
                let workflows = try await service.getWorkflows()
                withAnimation(.snappy) {
                    state = .selectingWorkflow(workflows)
                }
            } catch {
                withAnimation(.snappy) {
                    state = .failed(error.localizedDescription)
                }
            }
        }
    }

    func select(workflow: Workflow) {
        Task {
            do {
                let instance = try await service.startWorkflow(id: workflow.id)
                withAnimation(.snappy) {
                    state = .active(instance)
                }
            } catch {
                withAnimation(.snappy) {
                    state = .failed(error.localizedDescription)
                }
            }
        }
    }
}
