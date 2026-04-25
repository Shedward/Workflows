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
        case selectingWorkflow([WorkflowStart])
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
                let starts = try await service.getStartingWorkflows()
                withAnimation(.snappy) {
                    state = .selectingWorkflow(starts)
                }
            } catch {
                withAnimation(.snappy) {
                    state = .failed(error.localizedDescription)
                }
            }
        }
    }

    func select(_ start: WorkflowStart) {
        Task {
            do {
                let instance = try await service.startWorkflow(start)
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
