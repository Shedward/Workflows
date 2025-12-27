//
//  FromTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

import Core

extension Workflow {
    public func from(_ state: State, @ArrayBuilder<ToTransition<State>> build: () -> [ToTransition<State>]) -> [Transition<State>] {
        build().map { Transition(from: state, to: $0.to, process: $0.process) }
    }
}
