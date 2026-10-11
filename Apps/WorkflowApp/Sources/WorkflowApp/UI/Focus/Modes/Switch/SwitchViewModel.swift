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
    let starting = Command()
    private(set) var state: State = .activeWorkflows

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
        starting.reset()
        withAnimation(.snappy) {
            state = .activeWorkflows
        }
    }

    func activate(_ workflow: WorkflowInstance) {
        focus.setActiveWorkflow(workflow)
        focus.enter(.initial)
    }

    func start(_ start: WorkflowStart) {
        starting.run { [self] in
            let instance = try await focus.service.startWorkflow(start)
            withAnimation(.snappy) {
                state = .activeWorkflows
            }
            activate(instance)
        }
    }
}
