//
//  TransitionViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class TransitionViewModel {
    let transitions = Loading<[API.Transition]>()
    private(set) var runningTransition: API.Transition?
    private(set) var takeError: String?

    @ObservationIgnored unowned let focus: FocusViewModel

    init(focus: FocusViewModel) {
        self.focus = focus
    }

    func refresh() {
        guard let workflow = focus.activeWorkflow else {
            transitions.reset()
            return
        }
        transitions.load { [service = focus.service] in
            try await service.getTransitions(instanceId: workflow.id)
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
                takeError = nil
                refresh()
            } catch {
                takeError = error.localizedDescription
            }
            withAnimation(.snappy) {
                runningTransition = nil
            }
        }
    }
}
