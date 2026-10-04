import WorkflowEngine

struct StubService: UnregisteredService { }

@DataBindable
struct ProduceResult: Action {
    @Output var result: String
    func run() {
        result = "done"
    }
}

@DataBindable
struct ProduceRequiredData: Action {
    @Output var requiredData: String
    func run() {
        requiredData = "ready"
    }
}

@DataBindable
struct LinearWorkflow: Workflow {
    enum State: String, WorkflowState {
        case middle
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.middle)
        }

        on(.middle) {
            Finalize.toFinish()
        }
    }
}

@DataBindable
struct BranchesAgreeWorkflow: Workflow {
    enum State: String, WorkflowState {
        case fork
        case left
        case right
        case merge
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.fork)
        }

        on(.fork) {
            ProduceString.to(.left)
            ProduceString.to(.right)
        }

        on(.left, .right) {
            GoNextStep.to(.merge)
        }

        on(.merge) {
            ConsumeString.toFinish()
        }
    }
}

@DataBindable
struct DeclaredIOWorkflow: Workflow {
    enum State: String, WorkflowState {
        case consumed
    }

    @Input var data: String
    @Output var result: String

    var transitions: Transitions {
        onStart {
            ConsumeString.to(.consumed)
        }

        on(.consumed) {
            ProduceResult.toFinish()
        }
    }
}

@DataBindable
struct SatisfiedSubflowInputWorkflow: Workflow {
    enum State: String, WorkflowState {
        case beforeSubflow
        case afterSubflow
    }

    var transitions: Transitions {
        onStart {
            ProduceRequiredData.to(.beforeSubflow)
        }

        on(.beforeSubflow) {
            NeedySubflow.to(.afterSubflow)
        }

        on(.afterSubflow) {
            Finalize.toFinish()
        }
    }
}

@DataBindable
struct CycleWithManualExitWorkflow: Workflow {
    enum State: String, WorkflowState {
        case ping
        case pong
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.ping)
        }

        after(.ping) {
            GoNextStep.to(.pong)
        }

        after(.pong) {
            GoNextStep.to(.ping)
        }

        on(.ping) {
            Finalize.toFinish()
        }
    }
}

@DataBindable
struct WrongInputTypeWorkflow: Workflow {
    enum State: String, WorkflowState {
        case produced
    }

    var transitions: Transitions {
        onStart {
            ProduceInt.to(.produced)
        }

        on(.produced) {
            ConsumeString.toFinish()
        }
    }
}

@DataBindable
struct NeedyProvider: WorkflowStartProvider {
    @Dependency var service: UnregisteredService

    func starting() -> [WorkflowStart] {
        []
    }
}

@DataBindable
struct NeedyProviderWorkflow: Workflow {
    enum State: String, WorkflowState {
        case middle
    }

    var providers: [any WorkflowStartProvider] {
        NeedyProvider()
    }

    var transitions: Transitions {
        onStart {
            GoNextStep.to(.middle)
        }

        on(.middle) {
            Finalize.toFinish()
        }
    }
}
