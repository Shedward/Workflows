//
//  SwitchViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class SwitchViewModel {
    enum State {
        case activeWorkflows
        case newWorkflow
    }

    let activeWorkflows = Loading<[WorkflowInstance]>()
    let newWorkflows = Loading<[WorkflowStart]>()
    private(set) var state: State = .activeWorkflows
    private(set) var isStarting = false
    private(set) var startError: String?

    @ObservationIgnored unowned let focus: FocusViewModel

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        activeWorkflows.load { [service = focus.service] in
            try await service.getWorkflowInstances()
        }
    }

    func showNewWorkflow() {
        withAnimation(.snappy) {
            state = .newWorkflow
        }
        newWorkflows.load { [service = focus.service] in
            try await service.getStartingWorkflows()
        }
    }

    func showActiveWorkflows() {
        startError = nil
        withAnimation(.snappy) {
            state = .activeWorkflows
        }
    }

    func activate(_ workflow: WorkflowInstance) {
        focus.setActiveWorkflow(workflow)
        focus.enter(.initial)
    }

    func start(_ start: WorkflowStart) {
        guard !isStarting else {
            return
        }
        isStarting = true
        Task {
            do {
                let instance = try await focus.service.startWorkflow(start)
                startError = nil
                withAnimation(.snappy) {
                    state = .activeWorkflows
                }
                activate(instance)
            } catch {
                startError = error.localizedDescription
            }
            isStarting = false
        }
    }
}
