import Testing
@testable import WorkflowEngine

@Suite("Output binding")
struct OutputBindingTests {
    @Test func anOptionalOutputSetToNilIsStoredAsNull() throws {
        var action = ProducesOptional()
        try action.bind(CreateOutputStorage())
        action.run()

        var outputs = ReadOutputs(data: WorkflowData())
        try action.bind(&outputs)

        #expect(outputs.data.data["maybe"] == "null")
        #expect(try outputs.data.get("maybe") as String?? == .some(nil))
    }
}
