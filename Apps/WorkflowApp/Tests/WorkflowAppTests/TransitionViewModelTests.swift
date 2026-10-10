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

    init() {
        focus = FocusViewModel(service: WorkflowsService(rest: server))
    }

    private func loadTransitions(_ processIds: [String], of instanceId: String) async {
        server.on("GET /workflowInstances/\(instanceId)/transitions") {
            ListBody(items: processIds.map { API.Transition.stub($0) })
        }
        viewModel.refresh()
        await eventually("transitions are loaded") { viewModel.transitions.map(\.processId) == processIds }
    }

    @Test func refreshLoadsTransitionsOfTheActiveWorkflow() async {
        focus.setActiveWorkflow(.stub("w"))

        await loadTransitions(["Approve", "Reject"], of: "w")

        #expect(viewModel.error == nil)
        #expect(server.requests == ["GET /workflowInstances/w/transitions"])
    }

    @Test func refreshWithoutActiveWorkflowClearsTransitionsAndAsksNothing() async {
        focus.setActiveWorkflow(.stub("w"))
        await loadTransitions(["Approve"], of: "w")
        focus.setActiveWorkflow(nil)

        viewModel.refresh()

        #expect(viewModel.transitions.isEmpty)
        await settle()
        #expect(server.requests.count == 1)
    }

    @Test func failedRefreshShowsTheErrorAndKeepsTransitions() async {
        focus.setActiveWorkflow(.stub("w"))
        await loadTransitions(["Approve"], of: "w")
        server.on("GET /workflowInstances/w/transitions") { throw Boom() }

        viewModel.refresh()

        await eventually("error is shown") { viewModel.error == "boom" }
        #expect(viewModel.transitions.map(\.processId) == ["Approve"])
    }

    @Test func staleRefreshDoesNotOverwriteANewerOne() async {
        focus.setActiveWorkflow(.stub("w"))
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.stub("Stale")])
        }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.stub("Fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { viewModel.transitions.map(\.processId) == ["Fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.transitions.map(\.processId) == ["Fresh"])
    }

    @Test func takeMarksTheTransitionRunningThenUpdatesTheWorkflowAndItsTransitions() async {
        focus.setActiveWorkflow(.stub("w"))
        await loadTransitions(["Approve"], of: "w")
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.stub("w", state: "approved")
        }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.stub("Publish")]) }

        viewModel.take(.stub("Approve"))

        await eventually("transition is running") { viewModel.runningTransition?.processId == "Approve" }
        #expect(focus.activeWorkflow?.state == "working")
        takeResponse.open()
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(focus.activeWorkflow?.state == "approved")
        await eventually("next transitions are loaded") { viewModel.transitions.map(\.processId) == ["Publish"] }
        #expect(viewModel.error == nil)
    }

    @Test func takeThatFinishesTheWorkflowClearsTheActiveWorkflow() async {
        focus.setActiveWorkflow(.stub("w"))
        await loadTransitions(["Finish"], of: "w")
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.stub("w", finished: true) }

        viewModel.take(.stub("Finish"))

        await eventually("workflow is no longer active") { focus.activeWorkflow == nil }
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(viewModel.transitions.isEmpty)
        #expect(viewModel.error == nil)
    }

    @Test func failedTakeShowsTheErrorAndKeepsTheWorkflow() async {
        focus.setActiveWorkflow(.stub("w"))
        await loadTransitions(["Approve"], of: "w")
        server.on("POST /workflowInstances/w/takeTransition") { throw Boom() }

        viewModel.take(.stub("Approve"))

        await eventually("error is shown") { viewModel.error == "boom" }
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(focus.activeWorkflow?.state == "working")
        #expect(viewModel.transitions.map(\.processId) == ["Approve"])
    }

    @Test func aRefusedTakeShowsTheServersExplanation() async {
        focus.setActiveWorkflow(.stub("w"))
        let body = Data(#"{"userDescription":"Transition 'Approve' is not available","debugDescription":"..."}"#.utf8)
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 409, body: body, reason: "Wrong status code: 409")
        }

        viewModel.take(.stub("Approve"))

        await eventually("error is shown") { viewModel.error == "Transition 'Approve' is not available" }
    }

    @Test func aRefusedTakeWithoutAnErrorBodyShowsTheStatus() async {
        focus.setActiveWorkflow(.stub("w"))
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 502, body: Data("Bad Gateway".utf8), reason: "Wrong status code: 502")
        }

        viewModel.take(.stub("Approve"))

        await eventually("error is shown") { viewModel.error == "HTTP 502: Wrong status code: 502" }
    }

    @Test func takeIsIgnoredWhileAnotherTransitionIsRunning() async {
        focus.setActiveWorkflow(.stub("w"))
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.stub("w", finished: true)
        }

        viewModel.take(.stub("Approve"))
        await eventually("transition is running") { viewModel.runningTransition?.processId == "Approve" }
        viewModel.take(.stub("Reject"))
        takeResponse.open()
        await eventually("transition is done") { viewModel.runningTransition == nil }

        #expect(server.requests == ["POST /workflowInstances/w/takeTransition"])
    }

    @Test func takeWithoutActiveWorkflowDoesNothing() async {
        viewModel.take(.stub("Approve"))

        await settle()
        #expect(viewModel.runningTransition == nil)
        #expect(server.requests.isEmpty)
    }

    @Test func twoTakesInOneTurnSendOneRequest() async {
        focus.setActiveWorkflow(.stub("w"))
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.stub("w", finished: true) }

        viewModel.take(.stub("Approve"))
        viewModel.take(.stub("Reject"))

        #expect(viewModel.runningTransition?.processId == "Approve")
        await eventually("transition is done") { viewModel.runningTransition == nil }
        #expect(server.requests == ["POST /workflowInstances/w/takeTransition"])
    }

    @Test func clearingTheActiveWorkflowDropsAnInFlightRefreshAndTheError() async {
        focus.setActiveWorkflow(.stub("w"))
        server.on("GET /workflowInstances/w/transitions") { throw Boom() }
        viewModel.refresh()
        await eventually("error is shown") { viewModel.error == "boom" }
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.stub("Stale")])
        }
        viewModel.refresh()
        await eventually("request is sent") { server.requests.count == 2 }

        focus.setActiveWorkflow(nil)
        viewModel.refresh()
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.transitions.isEmpty)
        #expect(viewModel.error == nil)
    }
}
