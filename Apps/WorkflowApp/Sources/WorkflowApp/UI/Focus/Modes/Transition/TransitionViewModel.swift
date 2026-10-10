//
//  TransitionViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class TransitionViewModel: ErrorPresenting {
    private(set) var transitions: [API.Transition] = []
    private(set) var runningTransition: API.Transition?
    var error: String?

    @ObservationIgnored unowned let focus: FocusViewModel
    @ObservationIgnored private var refreshTask: Task<Void, Never>?

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        guard let workflow = focus.activeWorkflow else {
            refreshTask?.cancel()
            transitions = []
            error = nil
            return
        }
        refreshTask = run(cancelling: refreshTask) { [self] in
            let result = try await focus.service.getTransitions(instanceId: workflow.id)
            try Task.checkCancellation()
            transitions = result
            error = nil
        }
    }

    func take(_ transition: API.Transition) {
        guard let workflow = focus.activeWorkflow, runningTransition == nil else {
            return
        }
        withAnimation(.snappy) {
            runningTransition = transition
        }
        Task {
            do {
                let updated = try await focus.service.takeTransition(
                    instanceId: workflow.id,
                    transitionProcessId: transition.processId
                )
                if updated.finishedAt == nil {
                    focus.setActiveWorkflow(updated)
                } else {
                    focus.setActiveWorkflow(nil)
                }
                error = nil
                refresh()
            } catch {
                self.error = error.localizedDescription
            }
            withAnimation(.snappy) {
                runningTransition = nil
            }
        }
    }
}
