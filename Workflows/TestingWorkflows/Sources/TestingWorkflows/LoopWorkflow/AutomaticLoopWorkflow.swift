import WorkflowEngine

struct EnterLoop: Pass { }

/// `ping` and `pong` bounce between each other automatically and never change
/// the data, so the chain can only stop through runtime loop protection.
/// The manual `Finalize` exit from `ping` makes the cycle legal for static
/// validation, which only rejects cycles without a manual way out.
@DataBindable
struct AutomaticLoopWorkflow: Workflow {
    enum State: String, WorkflowState {
        case ping
        case pong
    }

    var transitions: Transitions {
        onStart {
            EnterLoop.to(.ping)
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
