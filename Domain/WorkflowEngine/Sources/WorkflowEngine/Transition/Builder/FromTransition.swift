//
//  FromTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

extension Workflow {
    public func on(_ state: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition(from: state, to: $0.to, process: $0.process, workflow: self, trigger: .manual) }
    }

    public func on(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { on($0, build: build) }
    }

    public func always(@ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        State.allCases.flatMap { on($0, build: build) }
    }

    public func after(_ initial: State = .initial, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        var currentState = initial

        let transitions = build().map { toTransition in
            let transition = Transition(
                from: currentState,
                to: toTransition.to,
                process: toTransition.process,
                workflow: self,
                trigger: .automatic
            )
            currentState = toTransition.to
            return transition
        }

        return transitions
    }

    public func after(_ states: State..., @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        states.flatMap { after($0, build: build) }
    }
}
