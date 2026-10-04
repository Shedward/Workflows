//
//  FocusViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class FocusViewModel {
    let service: WorkflowsService
    private(set) var currentMode: FocusModeID = .initial
    private(set) var activeWorkflow: WorkflowInstance?

    @ObservationIgnored private(set) lazy var switchVM = SwitchViewModel(focus: self)
    @ObservationIgnored private(set) lazy var transitionVM = TransitionViewModel(focus: self)

    init(service: WorkflowsService) {
        self.service = service
    }

    func enter(_ mode: FocusModeID) {
        withAnimation(.snappy) {
            currentMode = mode
        }
    }

    /// Single point of truth for active-workflow updates so cross-mode side effects
    /// can be added here later (analytics, cache invalidation, etc.).
    func setActiveWorkflow(_ workflow: WorkflowInstance?) {
        activeWorkflow = workflow
    }
}
