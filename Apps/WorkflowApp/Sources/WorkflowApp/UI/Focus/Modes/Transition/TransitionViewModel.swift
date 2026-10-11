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
    let taking = Command()

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
        guard let workflow = focus.activeWorkflow else {
            return
        }
        taking.run { [self] in
            let updated = try await focus.service.takeTransition(
                instanceId: workflow.id,
                transitionProcessId: transition.processId
            )
            focus.setActiveWorkflow(updated.finishedAt == nil ? updated : nil)
            refresh()
        }
    }
}
