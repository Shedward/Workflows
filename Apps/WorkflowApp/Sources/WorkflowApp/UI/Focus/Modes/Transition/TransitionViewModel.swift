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
    @ObservationIgnored private var takeTask: Task<Void, Never>?

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        guard let workflow = focus.activeWorkflow else {
            transitions = []
            return
        }
        refreshTask = latest(replacing: refreshTask) { [self] in
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
        takeTask = latest(replacing: takeTask) { [self] in
            withAnimation(.snappy) {
                runningTransition = transition
            }
            defer {
                withAnimation(.snappy) {
                    runningTransition = nil
                }
            }

            let updated = try await focus.service.takeTransition(
                instanceId: workflow.id,
                transitionProcessId: transition.processId
            )
            try Task.checkCancellation()
            focus.setActiveWorkflow(updated.finishedAt == nil ? updated : nil)
            error = nil
            refresh()
        }
    }
}
