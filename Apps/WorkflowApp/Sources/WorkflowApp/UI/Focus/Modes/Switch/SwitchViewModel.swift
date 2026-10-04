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

    private(set) var state: State = .activeWorkflows
    private(set) var activeWorkflows: [WorkflowInstance] = []
    private(set) var newWorkflows: [WorkflowStart] = []
    private(set) var error: String?

    @ObservationIgnored unowned let focus: FocusViewModel
    @ObservationIgnored private var refreshTask: Task<Void, Never>?
    @ObservationIgnored private var pickerTask: Task<Void, Never>?
    @ObservationIgnored private var startTask: Task<Void, Never>?

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        refreshTask?.cancel()
        refreshTask = Task { [service = focus.service] in
            do {
                let result = try await service.getWorkflowInstances()
                guard !Task.isCancelled else {
                    return
                }
                activeWorkflows = result
                error = nil
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func showNewWorkflow() {
        pickerTask?.cancel()
        pickerTask = Task { [service = focus.service] in
            do {
                let result = try await service.getStartingWorkflows()
                guard !Task.isCancelled else {
                    return
                }
                newWorkflows = result
                error = nil
                withAnimation(.snappy) {
                    state = .newWorkflow
                }
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
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
        startTask?.cancel()
        startTask = Task { [service = focus.service] in
            do {
                let instance = try await service.startWorkflow(start)
                guard !Task.isCancelled else {
                    return
                }
                state = .activeWorkflows
                activate(instance)
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
            }
        }
    }
}
