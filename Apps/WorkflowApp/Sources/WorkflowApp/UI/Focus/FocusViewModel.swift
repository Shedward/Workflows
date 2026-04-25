//
//  FocusViewModel.swift
//  WorkflowApp
//

import API
import SwiftUI

@Observable
@MainActor
final class FocusViewModel {
    static let modes: [FocusModeDescriptor] = [
        FocusModeDescriptor(
            id: .initial,
            bar: nil,
            make: { focus in AnyFocusMode(InitMode(focus: focus)) }
        ),
        FocusModeDescriptor(
            id: .switching,
            bar: ModeBarEntry(icon: "rectangle.stack", shortcut: "s"),
            make: { focus in AnyFocusMode(SwitchMode(focus: focus)) }
        ),
        FocusModeDescriptor(
            id: .transition,
            bar: ModeBarEntry(icon: "arrow.triangle.branch", shortcut: "t"),
            make: { focus in AnyFocusMode(TransitionMode(focus: focus)) }
        )
    ]

    static func descriptor(for id: FocusModeID) -> FocusModeDescriptor {
        guard let descriptor = modes.first(where: { $0.id == id }) else {
            fatalError("No descriptor for mode \(id) — registry out of sync with FocusModeID")
        }
        return descriptor
    }

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
