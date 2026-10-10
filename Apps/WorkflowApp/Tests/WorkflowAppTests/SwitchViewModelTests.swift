import API
import Rest
import Testing
@testable import WorkflowApp

@Suite("Switch view model")
@MainActor
struct SwitchViewModelTests {
    let server = FakeServer()
    let focus: FocusViewModel

    var viewModel: SwitchViewModel {
        focus.switchVM
    }

    init() {
        focus = FocusViewModel(service: WorkflowsService(rest: server))
    }

    @Test func refreshLoadsRunningWorkflows() async {
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.stub("a"), .stub("b")]) }

        viewModel.refresh()

        await eventually("running workflows are loaded") { viewModel.activeWorkflows.map(\.id) == ["a", "b"] }
        #expect(viewModel.error == nil)
        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func failedRefreshShowsTheErrorAndKeepsTheList() async {
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.stub("a")]) }
        server.on("GET /workflowInstances") { throw Boom() }

        viewModel.refresh()
        await eventually("running workflows are loaded") { viewModel.activeWorkflows.map(\.id) == ["a"] }
        viewModel.refresh()

        await eventually("error is shown") { viewModel.error == "boom" }
        #expect(viewModel.activeWorkflows.map(\.id) == ["a"])
    }

    @Test func successfulRefreshClearsTheError() async {
        server.on("GET /workflowInstances") { throw Boom() }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.stub("a")]) }

        viewModel.refresh()
        await eventually("error is shown") { viewModel.error == "boom" }
        viewModel.refresh()

        await eventually("error is cleared") { viewModel.error == nil }
        #expect(viewModel.activeWorkflows.map(\.id) == ["a"])
    }

    @Test func staleRefreshDoesNotOverwriteANewerOne() async {
        let staleResponse = Gate()
        server.on("GET /workflowInstances") {
            await staleResponse.wait()
            return ListBody(items: [WorkflowInstance.stub("stale")])
        }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.stub("fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { viewModel.activeWorkflows.map(\.id) == ["fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.activeWorkflows.map(\.id) == ["fresh"])
        #expect(viewModel.error == nil)
    }

    @Test func showNewWorkflowLoadsStartsAndOpensThePicker() async {
        server.on("GET /startingWorkflows") {
            ListBody(items: [WorkflowStart(id: "s1", workflowId: "Review", title: "Review PR", data: WorkflowData())])
        }

        viewModel.showNewWorkflow()

        await eventually("picker is shown") { viewModel.state == .newWorkflow }
        #expect(viewModel.newWorkflows.map(\.id) == ["s1"])
        #expect(viewModel.error == nil)
    }

    @Test func failedShowNewWorkflowShowsTheErrorAndStaysOnTheList() async {
        server.on("GET /startingWorkflows") { throw Boom() }

        viewModel.showNewWorkflow()

        await eventually("error is shown") { viewModel.error == "boom" }
        #expect(viewModel.state == .activeWorkflows)
        #expect(viewModel.newWorkflows.isEmpty)
    }

    @Test func showActiveWorkflowsLeavesThePicker() async {
        server.on("GET /startingWorkflows") { ListBody(items: [WorkflowStart]()) }
        viewModel.showNewWorkflow()
        await eventually("picker is shown") { viewModel.state == .newWorkflow }

        viewModel.showActiveWorkflows()

        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func activateMakesTheWorkflowActiveAndReturnsToTheInitialMode() {
        focus.enter(.switching)

        viewModel.activate(.stub("a"))

        #expect(focus.activeWorkflow?.id == "a")
        #expect(focus.currentMode == .initial)
    }

    @Test func startCreatesAnInstanceAndActivatesIt() async {
        let start = WorkflowStart(id: "s1", workflowId: "Review", title: nil, data: WorkflowData())
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { WorkflowInstance.stub("created") }
        focus.enter(.switching)
        viewModel.showNewWorkflow()
        await eventually("picker is shown") { viewModel.state == .newWorkflow }

        viewModel.start(start)

        await eventually("created instance is active") { focus.activeWorkflow?.id == "created" }
        #expect(viewModel.state == .activeWorkflows)
        #expect(focus.currentMode == .initial)
        #expect(viewModel.error == nil)
    }

    @Test func failedStartShowsTheErrorAndStaysInThePicker() async {
        let start = WorkflowStart(id: "s1", workflowId: "Review", title: nil, data: WorkflowData())
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { throw Boom() }
        focus.enter(.switching)
        viewModel.showNewWorkflow()
        await eventually("picker is shown") { viewModel.state == .newWorkflow }

        viewModel.start(start)

        await eventually("error is shown") { viewModel.error == "boom" }
        #expect(viewModel.state == .newWorkflow)
        #expect(focus.activeWorkflow == nil)
        #expect(focus.currentMode == .switching)
    }

    @Test func aReplacedRequestThatFailsDoesNotShowAnError() async {
        let staleResponse = Gate()
        server.on("GET /workflowInstances") {
            await staleResponse.wait()
            throw Boom()
        }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.stub("fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { viewModel.activeWorkflows.map(\.id) == ["fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.error == nil)
    }

    @Test func goingBackFromThePickerClearsTheError() async {
        let start = WorkflowStart(id: "s1", workflowId: "Review", title: nil, data: WorkflowData())
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { throw Boom() }
        viewModel.showNewWorkflow()
        await eventually("picker is shown") { viewModel.state == .newWorkflow }
        viewModel.start(start)
        await eventually("error is shown") { viewModel.error == "boom" }

        viewModel.showActiveWorkflows()

        #expect(viewModel.error == nil)
        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func aSecondStartWhileOneIsInFlightIsIgnored() async {
        let start = WorkflowStart(id: "s1", workflowId: "Review", title: nil, data: WorkflowData())
        let createResponse = Gate()
        server.on("POST /workflowInstances") {
            await createResponse.wait()
            return WorkflowInstance.stub("created")
        }

        viewModel.start(start)
        viewModel.start(start)
        await eventually("request is sent") { server.requests.count == 1 }
        viewModel.start(start)
        createResponse.open()
        await eventually("created instance is active") { focus.activeWorkflow?.id == "created" }
        await settle()

        #expect(server.requests == ["POST /workflowInstances"])
        #expect(!viewModel.isStarting)
    }
}
