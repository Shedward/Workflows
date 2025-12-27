//
//  TransitionsBuilder.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

@resultBuilder
public struct TransitionsBuilder<State: WorkflowState> {
    public static func buildBlock(_ transitions: Transition<State>) -> [Transition<State>] {
        [transitions]
    }

    public static func buildBlock(_ transitions: Transition<State>...) -> [Transition<State>] {
        transitions
    }

    public static func buildArray(_ components: [[Transition<State>]]) -> [Transition<State>] {
        components.flatMap { $0 }
    }
}

@resultBuilder
public struct ToTransitionBuilder<State: WorkflowState> {
    public static func buildBlock(_ component: ToTransition<State>) -> [ToTransition<State>] {
        [component]
    }
}
