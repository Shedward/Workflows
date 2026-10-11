import Testing
@testable import WorkflowApp

@Suite("Command")
@MainActor
struct CommandTests {
    @Test func runsOneActionAtATime() async {
        let command = Command()
        let response = Gate()
        var ran: [String] = []

        command.run {
            await response.wait()
            ran.append("first")
        }
        command.run {
            ran.append("second")
        }

        #expect(command.isRunning)
        response.open()
        await eventually("first run finishes") { !command.isRunning }
        #expect(ran == ["first"])
    }

    @Test func failedRunKeepsTheError() async {
        let command = Command()

        command.run { throw TestError() }

        await eventually("error is kept") { command.error?.localizedDescription == TestError.message }
        #expect(!command.isRunning)
    }

    @Test func nextRunClearsTheError() async {
        let command = Command()
        command.run { throw TestError() }
        await eventually("error is kept") { command.error != nil }

        command.run {}

        #expect(command.error == nil)
    }

    @Test func resetClearsTheError() async {
        let command = Command()
        command.run { throw TestError() }
        await eventually("error is kept") { command.error != nil }

        command.reset()

        #expect(command.error == nil)
    }
}
