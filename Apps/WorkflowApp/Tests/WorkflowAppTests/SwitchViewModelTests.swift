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
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.Mock.simple(id: "a"), .Mock.simple(id: "b")]) }

        viewModel.refresh()

        await eventually("running workflows are loaded") { viewModel.activeWorkflows.value?.map(\.id) == ["a", "b"] }
        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func failedRefreshShowsTheError() async {
        server.on("GET /workflowInstances") { throw TestError() }

        viewModel.refresh()

        await eventually("error is shown") { viewModel.activeWorkflows.error?.localizedDescription == TestError.message }
    }

    @Test func successfulRefreshReplacesTheError() async {
        server.on("GET /workflowInstances") { throw TestError() }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.Mock.simple(id: "a")]) }

        viewModel.refresh()
        await eventually("error is shown") { viewModel.activeWorkflows.error != nil }
        viewModel.refresh()

        await eventually("workflows are shown") { viewModel.activeWorkflows.value?.map(\.id) == ["a"] }
    }

    @Test func staleRefreshDoesNotOverwriteANewerOne() async {
        let staleResponse = Gate()
        server.on("GET /workflowInstances") {
            await staleResponse.wait()
            return ListBody(items: [WorkflowInstance.Mock.simple(id: "stale")])
        }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.Mock.simple(id: "fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { viewModel.activeWorkflows.value?.map(\.id) == ["fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.activeWorkflows.value?.map(\.id) == ["fresh"])
    }

    @Test func showNewWorkflowOpensThePickerAndLoadsStarts() async {
        server.on("GET /startingWorkflows") { ListBody(items: [WorkflowStart.Mock.simple(id: "s1", title: "Review PR")]) }

        viewModel.showNewWorkflow()

        #expect(viewModel.state == .newWorkflow)
        await eventually("starts are loaded") { viewModel.newWorkflows.value?.map(\.id) == ["s1"] }
    }

    @Test func failedShowNewWorkflowShowsTheErrorInThePicker() async {
        server.on("GET /startingWorkflows") { throw TestError() }

        viewModel.showNewWorkflow()

        await eventually("error is shown") { viewModel.newWorkflows.error?.localizedDescription == TestError.message }
        #expect(viewModel.state == .newWorkflow)
    }

    @Test func showActiveWorkflowsLeavesThePicker() {
        server.on("GET /startingWorkflows") { ListBody(items: [WorkflowStart]()) }
        viewModel.showNewWorkflow()

        viewModel.showActiveWorkflows()

        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func activateMakesTheWorkflowActiveAndReturnsToTheInitialMode() {
        focus.enter(.switching)

        viewModel.activate(.Mock.simple(id: "a"))

        #expect(focus.activeWorkflow?.id == "a")
        #expect(focus.currentMode == .initial)
    }

    @Test func startCreatesAnInstanceAndActivatesIt() async {
        let start = WorkflowStart.Mock.simple(id: "s1")
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { WorkflowInstance.Mock.simple(id: "created") }
        focus.enter(.switching)
        viewModel.showNewWorkflow()

        viewModel.start(start)

        await eventually("created instance is active") { focus.activeWorkflow?.id == "created" }
        #expect(viewModel.state == .activeWorkflows)
        #expect(focus.currentMode == .initial)
        #expect(viewModel.starting.error == nil)
    }

    @Test func failedStartShowsTheErrorAndStaysInThePicker() async {
        let start = WorkflowStart.Mock.simple(id: "s1")
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { throw TestError() }
        focus.enter(.switching)
        viewModel.showNewWorkflow()

        viewModel.start(start)

        await eventually("error is shown") { viewModel.starting.error?.localizedDescription == TestError.message }
        #expect(viewModel.state == .newWorkflow)
        #expect(focus.activeWorkflow == nil)
        #expect(focus.currentMode == .switching)
    }

    @Test func aReplacedRequestThatFailsDoesNotShowAnError() async {
        let staleResponse = Gate()
        server.on("GET /workflowInstances") {
            await staleResponse.wait()
            throw TestError()
        }
        server.on("GET /workflowInstances") { ListBody(items: [WorkflowInstance.Mock.simple(id: "fresh")]) }

        viewModel.refresh()
        await eventually("first request is sent") { server.requests.count == 1 }
        viewModel.refresh()
        await eventually("newer response is shown") { viewModel.activeWorkflows.value?.map(\.id) == ["fresh"] }
        staleResponse.open()
        await eventually("stale request is answered") { server.answered == 2 }
        await settle()

        #expect(viewModel.activeWorkflows.error == nil)
        #expect(viewModel.activeWorkflows.value?.map(\.id) == ["fresh"])
    }

    @Test func goingBackFromThePickerClearsTheStartError() async {
        let start = WorkflowStart.Mock.simple(id: "s1")
        server.on("GET /startingWorkflows") { ListBody(items: [start]) }
        server.on("POST /workflowInstances") { throw TestError() }
        viewModel.showNewWorkflow()
        viewModel.start(start)
        await eventually("error is shown") { viewModel.starting.error?.localizedDescription == TestError.message }

        viewModel.showActiveWorkflows()

        #expect(viewModel.starting.error == nil)
        #expect(viewModel.state == .activeWorkflows)
    }

    @Test func aSecondStartWhileOneIsInFlightIsIgnored() async {
        let start = WorkflowStart.Mock.simple(id: "s1")
        let createResponse = Gate()
        server.on("POST /workflowInstances") {
            await createResponse.wait()
            return WorkflowInstance.Mock.simple(id: "created")
        }

        viewModel.start(start)
        viewModel.start(start)
        await eventually("request is sent") { server.requests.count == 1 }
        viewModel.start(start)
        createResponse.open()
        await eventually("created instance is active") { focus.activeWorkflow?.id == "created" }
        await settle()

        #expect(server.requests.filter { $0.hasPrefix("POST") } == ["POST /workflowInstances"])
        #expect(!viewModel.starting.isRunning)
    }
}
