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

    private func activate(_ instanceId: String, with processIds: [String]) async {
        server.on("GET /workflowInstances/\(instanceId)/transitions") {
            ListBody(items: processIds.map { API.Transition.Mock.simple(processId: $0) })
        }
        focus.setActiveWorkflow(.Mock.simple(id: instanceId))
        await eventually("transitions are loaded") { loadedProcessIds == processIds }
    }

    @Test func activatingAWorkflowLoadsItsTransitions() async {
        await activate("w", with: ["Approve", "Reject"])

        #expect(server.requests == ["GET /workflowInstances/w/transitions"])
    }

    @Test func clearingTheActiveWorkflowClearsTransitionsAndAsksNothing() async {
        await activate("w", with: ["Approve"])

        focus.setActiveWorkflow(nil)

        #expect(loadedProcessIds == nil)
        await settle()
        #expect(server.requests.count == 1)
    }

    @Test func failedRefreshShowsTheError() async {
        await activate("w", with: ["Approve"])
        server.on("GET /workflowInstances/w/transitions") { throw TestError() }

        viewModel.refresh()

        await eventually("error is shown") { viewModel.transitions.error?.localizedDescription == TestError.message }
    }

    @Test func staleRefreshDoesNotOverwriteANewerOne() async {
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.Mock.simple(processId: "Stale")])
        }
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await eventually("first request is sent") { server.requests.count == 1 }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Fresh")]) }

        viewModel.refresh()
        await eventually("newer response is shown") { loadedProcessIds == ["Fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(loadedProcessIds == ["Fresh"])
    }

    @Test func takeMarksTheTransitionRunningThenUpdatesTheWorkflowAndItsTransitions() async {
        await activate("w", with: ["Approve"])
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.Mock.simple(id: "w", state: "approved")
        }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Publish")]) }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("transition is running") { viewModel.taking.isRunning }
        #expect(focus.activeWorkflow?.state == "working")
        takeResponse.open()
        await eventually("transition is done") { !viewModel.taking.isRunning }
        #expect(focus.activeWorkflow?.state == "approved")
        await eventually("next transitions are loaded") { loadedProcessIds == ["Publish"] }
        #expect(viewModel.taking.error == nil)
    }

    @Test func takeThatFinishesTheWorkflowClearsTheActiveWorkflow() async {
        await activate("w", with: ["Finish"])
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.Mock.simple(id: "w", finished: true) }

        viewModel.take(.Mock.simple(processId: "Finish"))

        await eventually("workflow is no longer active") { focus.activeWorkflow == nil }
        await eventually("transition is done") { !viewModel.taking.isRunning }
        #expect(loadedProcessIds == nil)
        #expect(viewModel.taking.error == nil)
    }

    @Test func failedTakeShowsTheErrorAndKeepsTheWorkflow() async {
        await activate("w", with: ["Approve"])
        server.on("POST /workflowInstances/w/takeTransition") { throw TestError() }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.taking.error?.localizedDescription == TestError.message }
        await eventually("transition is done") { !viewModel.taking.isRunning }
        #expect(focus.activeWorkflow?.state == "working")
        #expect(loadedProcessIds == ["Approve"])
    }

    @Test func aRefusedTakeShowsTheServersExplanation() async {
        await activate("w", with: ["Approve"])
        let body = Data(#"{"userDescription":"Transition 'Approve' is not available","debugDescription":"..."}"#.utf8)
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 409, body: body, reason: "Wrong status code: 409")
        }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.taking.error?.localizedDescription == "Transition 'Approve' is not available" }
    }

    @Test func aRefusedTakeWithoutAnErrorBodyShowsTheStatus() async {
        await activate("w", with: ["Approve"])
        server.on("POST /workflowInstances/w/takeTransition") {
            throw ResponseRejected(statusCode: 502, body: Data("Bad Gateway".utf8), reason: "Wrong status code: 502")
        }

        viewModel.take(.Mock.simple(processId: "Approve"))

        await eventually("error is shown") { viewModel.taking.error?.localizedDescription == "HTTP 502: Wrong status code: 502" }
    }

    @Test func takeIsIgnoredWhileAnotherTransitionIsRunning() async {
        await activate("w", with: ["Approve", "Reject"])
        let takeResponse = Gate()
        server.on("POST /workflowInstances/w/takeTransition") {
            await takeResponse.wait()
            return WorkflowInstance.Mock.simple(id: "w", finished: true)
        }

        viewModel.take(.Mock.simple(processId: "Approve"))
        await eventually("transition is running") { viewModel.taking.isRunning }
        viewModel.take(.Mock.simple(processId: "Reject"))
        takeResponse.open()
        await eventually("transition is done") { !viewModel.taking.isRunning }

        #expect(server.requests == ["GET /workflowInstances/w/transitions", "POST /workflowInstances/w/takeTransition"])
    }

    @Test func takeWithoutActiveWorkflowDoesNothing() async {
        viewModel.take(.Mock.simple(processId: "Approve"))

        await settle()
        #expect(!viewModel.taking.isRunning)
        #expect(server.requests.isEmpty)
    }

    @Test func twoTakesInOneTurnSendOneRequest() async {
        await activate("w", with: ["Approve", "Reject"])
        server.on("POST /workflowInstances/w/takeTransition") { WorkflowInstance.Mock.simple(id: "w", finished: true) }

        viewModel.take(.Mock.simple(processId: "Approve"))
        viewModel.take(.Mock.simple(processId: "Reject"))

        #expect(viewModel.taking.isRunning)
        await eventually("transition is done") { !viewModel.taking.isRunning }
        #expect(server.requests == ["GET /workflowInstances/w/transitions", "POST /workflowInstances/w/takeTransition"])
    }

    private func activateFailed(_ instanceId: String) async {
        server.on("GET /workflowInstances/\(instanceId)/transitions") {
            ListBody(items: [API.Transition.Mock.simple(processId: "Upload")])
        }
        focus.setActiveWorkflow(.Mock.failed(id: instanceId, error: "Network is unreachable"))
        await eventually("transitions are loaded") { loadedProcessIds == ["Upload"] }
    }

    @Test func retryUpdatesTheWorkflowAndClearsTheFailure() async {
        await activateFailed("w")
        server.on("POST /workflowInstances/w/retry") { WorkflowInstance.Mock.simple(id: "w", state: "uploaded") }
        server.on("GET /workflowInstances/w/transitions") { ListBody(items: [API.Transition.Mock.simple(processId: "Publish")]) }

        viewModel.retry()

        await eventually("transition is done") { !viewModel.taking.isRunning && focus.activeWorkflow?.state == "uploaded" }
        #expect(viewModel.failure() == nil)
        await eventually("next transitions are loaded") { loadedProcessIds == ["Publish"] }
        #expect(viewModel.taking.error == nil)
    }

    @Test func retryThatFailsAgainKeepsTheFailureAndShowsTheNewError() async {
        await activateFailed("w")
        server.on("POST /workflowInstances/w/retry") { throw TestError() }

        viewModel.retry()

        await eventually("error is shown") { viewModel.taking.error?.localizedDescription == TestError.message }
        await eventually("transition is done") { !viewModel.taking.isRunning }
        #expect(viewModel.failure()?.userDescription == "Network is unreachable")
    }

    @Test func retryWithoutAFailureDoesNothing() async {
        await activate("w", with: ["Approve"])

        viewModel.retry()

        await settle()
        #expect(server.requests == ["GET /workflowInstances/w/transitions"])
    }

    @Test func clearingTheActiveWorkflowDropsAnInFlightRefreshAndTheError() async {
        server.on("GET /workflowInstances/w/transitions") { throw TestError() }
        focus.setActiveWorkflow(.Mock.simple(id: "w"))
        await eventually("error is shown") { viewModel.transitions.error != nil }
        let staleResponse = Gate()
        server.on("GET /workflowInstances/w/transitions") {
            await staleResponse.wait()
            return ListBody(items: [API.Transition.Mock.simple(processId: "Stale")])
        }
        viewModel.refresh()
        await eventually("request is sent") { server.requests.count == 2 }

        focus.setActiveWorkflow(nil)
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(loadedProcessIds == nil)
        #expect(viewModel.transitions.error == nil)
    }
}
