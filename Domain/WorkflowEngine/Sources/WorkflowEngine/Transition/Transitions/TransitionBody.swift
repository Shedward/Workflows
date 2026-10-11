import Core

/// The three client-visible error texts of one transition kind.
struct BodyFailures {
    let prepare: String
    let run: String
    let finish: String
}

extension TransitionProcess where Self: DataBindable {
    /// The life cycle shared by every transition body that reads and writes workflow data:
    /// bind inputs, create output storage, bind the user's answers if there are any, inject
    /// dependencies, run `body` on the bound copy, then write its outputs into the instance data.
    func runBody<Value>(
        in context: inout WorkflowContext,
        answers: WorkflowData? = nil,
        failures: BodyFailures,
        _ body: @Sendable (Self) async throws -> Value
    ) async throws -> Value {
        var bound = self

        try Failure.wrap(failures.prepare) {
            try bound.bind(BindInputs(data: context.instance.data))
            try bound.bind(CreateOutputStorage())
            if let answers {
                try bound.bind(BindAskInputs(data: answers))
            }
            try bound.bind(SetDependencies(container: context.dependencies))
        }

        let running = bound
        let value = try await Failure.wrap(failures.run) {
            try await body(running)
        }

        var outputs = ReadOutputs(data: context.instance.data)
        try Failure.wrap(failures.finish) {
            try bound.bind(&outputs)
        }
        context.instance.data = outputs.data

        return value
    }
}
