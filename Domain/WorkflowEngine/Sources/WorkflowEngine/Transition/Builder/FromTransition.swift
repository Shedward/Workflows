//
//  FromTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

extension Workflow {
    public func onStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        transitions(from: State.start, trigger: .manual, build())
    }

    public func on(_ state: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        transitions(from: state.id, trigger: .manual, build())
    }

    public func on(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { on($0, build: build) }
    }

    public func always(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        State.allCases.flatMap { on($0, build: build) }
    }

    public func afterStart(_ build: () -> ToTransition<State>) -> [Transition<State>] {
        transitions(from: State.start, trigger: .automatic, [build()])
    }

    public func after(_ state: State, _ build: () -> ToTransition<State>) -> [Transition<State>] {
        transitions(from: state.id, trigger: .automatic, [build()])
    }

    public func after(_ states: State..., build: () -> ToTransition<State>) -> [Transition<State>] {
        states.flatMap { after($0, build) }
    }

    public func chainedAfterStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        chain(from: State.start, build(), builderName: "chainedAfterStart")
    }

    public func chainedAfter(_ initial: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        chain(from: initial.id, build(), builderName: "chainedAfter")
    }

    private func transitions(
        from state: StateID,
        trigger: TransitionTrigger,
        _ steps: [ToTransition<State>]
    ) -> [Transition<State>] {
        steps.map { Transition(from: state, targets: $0.targets, process: $0.process, workflow: self, trigger: trigger) }
    }

    /// Automatic transitions where each step starts from the state the previous one leads to.
    private func chain(from initial: StateID, _ steps: [ToTransition<State>], builderName: String) -> [Transition<State>] {
        var currentStateId = initial

        return steps.map { step in
            assert(
                step.targets.count <= 1,
                "Branching transitions cannot be used in chains. Use on() instead of \(builderName)()."
            )
            let transition = Transition<State>(
                from: currentStateId,
                targets: step.targets,
                process: step.process,
                workflow: self,
                trigger: .automatic
            )
            currentStateId = step.targets[0]
            return transition
        }
    }
}
