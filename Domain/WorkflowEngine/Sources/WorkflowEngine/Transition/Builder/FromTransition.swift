//
//  FromTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

extension Workflow {
    public func onStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition<State>(from: State.start, to: $0.to, process: $0.process, workflow: self, trigger: .manual) }
    }

    public func on(_ state: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition(from: state.id, to: $0.to, process: $0.process, workflow: self, trigger: .manual) }
    }

    public func on(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { on($0, build: build) }
    }

    public func always(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        State.allCases.flatMap { on($0, build: build) }
    }

    public func afterStart(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        var currentStateId = State.start

        let transitions = build().map { toTransition in
            let transition = Transition<State>(
                from: currentStateId,
                to: toTransition.to,
                process: toTransition.process,
                workflow: self,
                trigger: .automatic
            )
            currentStateId = toTransition.to
            return transition
        }

        return transitions
    }

    public func after(_ initial: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        var currentStateId = initial.id

        let transitions = build().map { toTransition in
            let transition = Transition<State>(
                from: currentStateId,
                to: toTransition.to,
                process: toTransition.process,
                workflow: self,
                trigger: .automatic
            )
            currentStateId = toTransition.to
            return transition
        }

        return transitions
    }

    public func after(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { after($0, build: build) }
    }
}
