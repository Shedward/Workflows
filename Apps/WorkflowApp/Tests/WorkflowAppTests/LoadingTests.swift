import Testing
@testable import WorkflowApp

@Suite("Loading")
@MainActor
struct LoadingTests {
    @Test func loadStoresTheValue() async {
        let loading = Loading<Int>()

        loading.load { 42 }

        await eventually("value is loaded") { loading.value == 42 }
    }

    @Test func failedLoadStoresTheError() async {
        let loading = Loading<Int>()

        loading.load { throw TestError() }

        await eventually("error is stored") { loading.error?.localizedDescription == TestError.message }
        #expect(loading.value == nil)
    }

    @Test func slowLoadKeepsThePreviousValueUntilTheDelayPasses() async {
        let loading = Loading<Int>(.loaded(1), loadingDelay: .milliseconds(100))
        let response = Gate()
        loading.load {
            await response.wait()
            return 2
        }

        await settle(for: .milliseconds(30))
        #expect(loading.value == 1)
        await eventually("loading is shown") { loading.isLoading }
        response.open()

        await eventually("new value is loaded") { loading.value == 2 }
    }

    @Test func theLastLoadWins() async {
        let loading = Loading<String>()
        let staleResponse = Gate()
        loading.load {
            await staleResponse.wait()
            return "stale"
        }

        loading.load { "fresh" }
        await eventually("fresh value is loaded") { loading.value == "fresh" }
        staleResponse.open()
        await settle()

        #expect(loading.value == "fresh")
    }

    @Test func resetDropsTheRequestInFlight() async {
        let loading = Loading<String>()
        let response = Gate()
        loading.load {
            await response.wait()
            return "late"
        }

        loading.reset()
        response.open()
        await settle()

        #expect(loading.value == nil)
        #expect(loading.error == nil)
        #expect(!loading.isLoading)
    }
}
