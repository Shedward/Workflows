//
//  FromTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

extension Workflow {
    public func onStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition<State>(from: State.start, targets: $0.targets, process: $0.process, workflow: self, trigger: .manual) }
    }

    public func on(_ state: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition(from: state.id, targets: $0.targets, process: $0.process, workflow: self, trigger: .manual) }
    }

    public func on(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { on($0, build: build) }
    }

    public func always(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        State.allCases.flatMap { on($0, build: build) }
    }

    public func afterStart(_ build: () -> ToTransition<State>) -> [Transition<State>] {
        let toTransition = build()
        return [Transition<State>(
            from: State.start, targets: toTransition.targets, process: toTransition.process, workflow: self, trigger: .automatic
        )]
    }

    public func after(_ state: State, _ build: () -> ToTransition<State>) -> [Transition<State>] {
        let toTransition = build()
        return [Transition<State>(from: state.id, targets: toTransition.targets, process: toTransition.process, workflow: self, trigger: .automatic)]
    }

    public func after(_ states: State..., build: () -> ToTransition<State>) -> [Transition<State>] {
        states.flatMap { after($0, build) }
    }

    public func chainedAfterStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        var currentStateId = State.start

        return build().map { toTransition in
            assert(
                toTransition.targets.count <= 1,
                "Branching transitions cannot be used in chains. Use on() instead of chainedAfterStart()."
            )
            let transition = Transition<State>(
                from: currentStateId,
                targets: toTransition.targets,
                process: toTransition.process,
                workflow: self,
                trigger: .automatic
            )
            currentStateId = toTransition.targets[0]
            return transition
        }
    }

    public func chainedAfter(_ initial: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        var currentStateId = initial.id

        return build().map { toTransition in
            assert(
                toTransition.targets.count <= 1,
                "Branching transitions cannot be used in chains. Use on() instead of chainedAfter()."
            )
            let transition = Transition<State>(
                from: currentStateId,
                targets: toTransition.targets,
                process: toTransition.process,
                workflow: self,
                trigger: .automatic
            )
            currentStateId = toTransition.targets[0]
            return transition
        }
    }

    public func chainAfter(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { chainedAfter($0, build: build) }
    }
}
