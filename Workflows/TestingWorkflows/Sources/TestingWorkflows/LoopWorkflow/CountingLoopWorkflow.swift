import WorkflowEngine

@DataBindable
struct StartCounting: Action {
    @Output var counter: Int

    func run() {
        counter = 0
    }
}

@DataBindable
struct CountStep: Action {
    @Input var counter: Int
    @Output(key: "counter") var nextCounter: Int

    func run() {
        nextCounter = counter + 1
    }
}

/// `tick` and `tock` bounce between each other automatically and bump `counter`
/// on every step. Because the data changes each time, no step ever repeats, so
/// only the automatic step cap can stop the chain.
@DataBindable
struct CountingLoopWorkflow: Workflow {
    enum State: String, WorkflowState {
        case tick
        case tock
    }

    var transitions: Transitions {
        onStart {
            StartCounting.to(.tick)
        }

        after(.tick) {
            CountStep.to(.tock)
        }

        after(.tock) {
            CountStep.to(.tick)
        }

        on(.tick) {
            Finalize.toFinish()
        }
    }
}
