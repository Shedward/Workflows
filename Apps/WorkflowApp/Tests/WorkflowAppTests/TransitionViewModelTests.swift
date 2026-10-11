import API
import Foundation
import Rest
import Testing
@testable import WorkflowApp

@Suite("Transition view model")
@MainActor
struct TransitionViewModelTests {
    let server = FakeServer()
    let focus: FocusViewModel

    var viewModel: TransitionViewModel {
        focus.transitionVM
    }

    var loadedProcessIds: [String]? {
        viewModel.transitions.value?.map(\.processId)
    }

    init() {
        focus = FocusViewModel(service: WorkflowsService(rest: server))
    }

    private func loadTransitions(_ processIds: [String], of instanceId: String) async {
        server.on("GET /workflowInstances/\(instanceId)/transitions") {
            ListBody(items: processIds.map { API.Transition.Mock.simple(processId: $0) })
        }
        viewModel.refresh()
        await eventually("transitions are loaded") { loadedProcessIds == processIds }
    }

    @Test func refreshLoadsTransitionsOfTheActiveWorkflow() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))

        await loadTransitions(["Approve", "Reject"], of: "w")

        #expect(server.requests == ["GET /workflowInstances/w/transitions"])
    }

    @Test func refreshWithoutActiveWorkflowClearsTransitionsAndAsksNothing() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await loadTransitions(["Approve"], of: "w")
        focus.setActiveWorkflow(nil)

        viewModel.refresh()

        #expect(loadedProcessIds == nil)
        await settle()
        #expect(server.requests.count == 1)
    }

    @Test func failedRefreshShowsTheError() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await loadTransitions(["Approve"], of: "w")
        server.on("GET /workflowInstances/w/transitions") { throw TestError() }

        viewModel.refresh()

        await eventually("error is shown") { viewModel.transitions.error?.localizedDescription == TestError.message }
    }

    @Test func staleRefreshDoesNotOverwriteANewerOne() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.Mock.simple(processId: "Stale")])
        }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { loadedProcessIds == ["Fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(loadedProcessIds == ["Fresh"])
    }

    @Test func takeMarksTheTransitionRunningThenUpdatesTheWorkflowAndItsTransitions() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await loadTransitions(["Approve"], of: "w")
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.Mock.simple(id: "w", state: "approved")
        }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Publish")]) }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("transition is running") { viewModel.runningTransition?.processId == "Approve" }
        #expect(focus.activeWorkflow?.state == "working")
        takeResponse.open()
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(focus.activeWorkflow?.state == "approved")
        await eventually("next transitions are loaded") { loadedProcessIds == ["Publish"] }
        #expect(viewModel.takeError == nil)
    }

    @Test func takeThatFinishesTheWorkflowClearsTheActiveWorkflow() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await loadTransitions(["Finish"], of: "w")
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.Mock.simple(id: "w", finished: true) }

        viewModel.take(.Mock.simple(processId: "Finish"))

        await eventually("workflow is no longer active") { focus.activeWorkflow == nil }
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(loadedProcessIds == nil)
        #expect(viewModel.takeError == nil)
    }

    @Test func failedTakeShowsTheErrorAndKeepsTheWorkflow() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await loadTransitions(["Approve"], of: "w")
        server.on("POST /workflowInstances/w/takeTransition") { throw TestError() }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.takeError == TestError.message }
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(focus.activeWorkflow?.state == "working")
        #expect(loadedProcessIds == ["Approve"])
    }

    @Test func aRefusedTakeShowsTheServersExplanation() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        let body = Data(#"{"userDescription":"Transition 'Approve' is not available","debugDescription":"..."}"#.utf8)
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 409, body: body, reason: "Wrong status code: 409")
        }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.takeError == "Transition 'Approve' is not available" }
    }

    @Test func aRefusedTakeWithoutAnErrorBodyShowsTheStatus() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 502, body: Data("Bad Gateway".utf8), reason: "Wrong status code: 502")
        }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.takeError == "HTTP 502: Wrong status code: 502" }
    }

    @Test func takeIsIgnoredWhileAnotherTransitionIsRunning() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.Mock.simple(id: "w", finished: true)
        }

        viewModel.take(.Mock.simple(processId: "Approve"))
        await eventually("transition is running") { viewModel.runningTransition?.processId == "Approve" }
        viewModel.take(.Mock.simple(processId: "Reject"))
        takeResponse.open()
        await eventually("transition is done") { viewModel.runningTransition == nil }

        #expect(server.requests == ["POST /workflowInstances/w/takeTransition"])
    }

    @Test func takeWithoutActiveWorkflowDoesNothing() async {
        viewModel.take(.Mock.simple(processId: "Approve"))

        await settle()
        #expect(viewModel.runningTransition == nil)
        #expect(server.requests.isEmpty)
    }

    @Test func twoTakesInOneTurnSendOneRequest() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.Mock.simple(id: "w", finished: true) }

        viewModel.take(.Mock.simple(processId: "Approve"))
        viewModel.take(.Mock.simple(processId: "Reject"))

        #expect(viewModel.runningTransition?.processId == "Approve")
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(server.requests == ["POST /workflowInstances/w/takeTransition"])
    }

    @Test func clearingTheActiveWorkflowDropsAnInFlightRefreshAndTheError() async {
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        server.on("GET /workflowInstances/w/transitions") { throw TestError() }
        viewModel.refresh()
        await eventually("error is shown") { viewModel.transitions.error != nil }
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.Mock.simple(processId: "Stale")])
        }
        viewModel.refresh()
        await eventually("request is sent") { server.requests.count == 2 }

        focus.setActiveWorkflow(nil)
        viewModel.refresh()
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(loadedProcessIds == nil)
        #expect(viewModel.transitions.error == nil)
    }
}
