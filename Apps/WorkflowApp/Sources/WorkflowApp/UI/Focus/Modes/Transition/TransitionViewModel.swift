//
//  TransitionViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class TransitionViewModel {
    private(set) var transitions: [API.Transition] = []
    private(set) var runningTransition: API.Transition?
    private(set) var error: String?

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
        refreshTask?.cancel()
        refreshTask = Task { [service = focus.service] in
            do {
                let result = try await service.getTransitions(instanceId: workflow.id)
                guard !Task.isCancelled else {
                    return
                }
                transitions = result
                error = nil
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
            }
        }
    }

    func take(_ transition: API.Transition) {
        guard let workflow = focus.activeWorkflow, runningTransition == nil else {
            return
        }
        takeTask?.cancel()
        takeTask = Task { [service = focus.service] in
            withAnimation(.snappy) {
                runningTransition = transition
            }
            do {
                let updated = try await service.takeTransition(
                    instanceId: workflow.id,
                    transitionProcessId: transition.processId
                )
                guard !Task.isCancelled else {
                    return
                }
                if updated.finishedAt != nil {
                    focus.setActiveWorkflow(nil)
                } else {
                    focus.setActiveWorkflow(updated)
                }
                error = nil
                refresh()
            } catch is CancellationError {
                return
            } catch {
                self.error = error.localizedDescription
            }
            withAnimation(.snappy) {
                runningTransition = nil
            }
        }
    }
}
