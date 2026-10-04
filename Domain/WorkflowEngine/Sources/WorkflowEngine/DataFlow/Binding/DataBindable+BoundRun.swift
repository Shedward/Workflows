import Core

extension DataBindable {
    /// The life cycle shared by every transition body that reads and writes workflow data:
    /// bind inputs, create output storage, inject dependencies, run `body` on the bound copy,
    /// then write its outputs back into the instance data.
    ///
    /// `answers` carries the user's reply for an `Asking` transition. `prepareVerb` and `runVerb`
    /// exist only to keep the wording of the wrapped errors as it always was for each kind.
    func withBoundData<Value>(
        in context: inout WorkflowContext,
        kind: String,
        prepareVerb: String = "prepare",
        runVerb: String = "run",
        answers: WorkflowData? = nil,
        _ body: @Sendable (Self) async throws -> Value
    ) async throws -> Value {
        let name = "\(kind) \(type(of: self))"
        var bound = self

        try Failure.wrap("Failed to \(prepareVerb) \(name)") {
            try bound.bind(BindInputs(data: context.instance.data))
            try bound.bind(CreateOutputStorage())
            if let answers {
                try bound.bind(BindAskInputs(data: answers))
            }
            try bound.bind(SetDependencies(container: context.dependencies))
        }

        let running = bound
        let value = try await Failure.wrap("Failed to \(runVerb) \(name)") {
            try await body(running)
        }

        var outputs = ReadOutputs(data: context.instance.data)
        try Failure.wrap("Failed to finish \(name)") {
            try bound.bind(&outputs)
        }
        context.instance.data = outputs.data

        return value
    }
}
