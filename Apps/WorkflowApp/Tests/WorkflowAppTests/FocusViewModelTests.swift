import API
import Testing
@testable import WorkflowApp

@Suite("Focus view model")
@MainActor
struct FocusViewModelTests {
    let focus = FocusViewModel(service: WorkflowsService(rest: FakeServer()))

    @Test func startsInTheInitialModeWithoutAnActiveWorkflow() {
        #expect(focus.currentMode == .initial)
        #expect(focus.activeWorkflow == nil)
    }

    @Test func enterSwitchesTheMode() {
        focus.enter(.transition)
        #expect(focus.currentMode == .transition)

        focus.enter(.initial)
        #expect(focus.currentMode == .initial)
    }

    @Test func activeWorkflowCanBeSetAndCleared() {
        focus.setActiveWorkflow(.stub("a"))
        #expect(focus.activeWorkflow?.id == "a")

        focus.setActiveWorkflow(nil)
        #expect(focus.activeWorkflow == nil)
    }

    @Test func modeBarOffersSwitchingAndTransitionWithTheirShortcuts() {
        let entries = FocusViewModel.modes.compactMap { mode in
            mode.bar.map { "\(mode.id) \($0.icon) cmd+\($0.shortcut.character)" }
        }

        #expect(entries == [
            "switching rectangle.stack cmd+s",
            "transition arrow.triangle.branch cmd+t"
        ])
    }
}
