//
//  SwitchViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class SwitchViewModel: ErrorPresenting {
    enum State {
        case activeWorkflows
        case newWorkflow
    }

    private(set) var state: State = .activeWorkflows
    private(set) var activeWorkflows: [WorkflowInstance] = []
    private(set) var newWorkflows: [WorkflowStart] = []
    var error: String?

    @ObservationIgnored unowned let focus: FocusViewModel
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var pickerTask: Task<Void, Never>?
    @ObservationIgnored private var startTask: Task<Void, Never>?

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        refreshTask = latest(replacing: refreshTask) { [self] in
            let result = try await focus.service.getWorkflowInstances()
            try Task.checkCancellation()
            activeWorkflows = result
            error = nil
        }
    }

    func showNewWorkflow() {
        pickerTask = latest(replacing: pickerTask) { [self] in
            let result = try await focus.service.getStartingWorkflows()
            try Task.checkCancellation()
            newWorkflows = result
            error = nil
            withAnimation(.snappy) {
                state = .newWorkflow
            }
        }
    }

    func showActiveWorkflows() {
        withAnimation(.snappy) {
            state = .activeWorkflows
        }
    }

    func activate(_ workflow: WorkflowInstance) {
        focus.setActiveWorkflow(workflow)
        focus.enter(.initial)
    }

    func start(_ start: WorkflowStart) {
        startTask = latest(replacing: startTask) { [self] in
            let instance = try await focus.service.startWorkflow(start)
            try Task.checkCancellation()
            state = .activeWorkflows
            activate(instance)
        }
    }
}
