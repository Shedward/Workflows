import API
import Rest
import Testing
@testable import WorkflowApp

@Suite("Focus view model")
@MainActor
struct FocusViewModelTests {
    let server = FakeServer()
    let focus: FocusViewModel

    init() {
        focus = FocusViewModel(service: WorkflowsService(rest: server))
    }

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

    @Test func enteringSwitchingLoadsTheRunningWorkflows() async {
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.Mock.simple(id: "a")]) }

        focus.enter(.switching)

        await eventually("running workflows are loaded") { focus.switchVM.activeWorkflows.value?.map(\.id) == ["a"] }
    }

    @Test func enteringTransitionLoadsTheTransitionsOfTheActiveWorkflow() async {
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Approve")]) }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Reject")]) }
        focus.setActiveWorkflow(.Mock.simple(id: "w"))

        focus.enter(.transition)

        await eventually("transitions are reloaded") { focus.transitionVM.transitions.value?.map(\.processId) == ["Reject"] }
    }

    @Test func settingTheActiveWorkflowLoadsItsTransitions() async {
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Approve")]) }

        focus.setActiveWorkflow(.Mock.simple(id: "w"))

        #expect(focus.activeWorkflow?.id == "w")
        await eventually("transitions are loaded") { focus.transitionVM.transitions.value?.map(\.processId) == ["Approve"] }
    }

    @Test func clearingTheActiveWorkflowResetsTheTransitions() async {
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Approve")]) }
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await eventually("transitions are loaded") { focus.transitionVM.transitions.value != nil }

        focus.setActiveWorkflow(nil)

        #expect(focus.activeWorkflow == nil)
        #expect(focus.transitionVM.transitions.value == nil)
        await settle()
        #expect(server.requests.count == 1)
    }

    @Test func modeBarOffersSwitchingAndTransitionWithTheirShortcuts() {
        let entries = FocusModeID.allCases.compactMap { mode in
            mode.bar.map { "\(mode) \($0.icon) cmd+\($0.shortcut.character)" }
        }

        #expect(entries == [
            "switching rectangle.stack cmd+s",
            "transition arrow.triangle.branch cmd+t"
        ])
    }
}
