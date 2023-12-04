//
//  TransitionsBuilder.swift
//
//
//  Created by Vlad Maltsev on 04.12.2023.
//

@resultBuilder
public struct TransitionsBuilder<S: State> {
    
    public static func buildEither(first component: [AnyTransition<S>]) -> [AnyTransition<S>] {
        component
    }
    
    public static func buildEither(second component: [AnyTransition<S>]) -> [AnyTransition<S>] {
        component
    }
    
    public static func buildOptional(_ component: [AnyTransition<S>]?) -> [AnyTransition<S>] {
        component ?? []
    }
    
    public static func buildExpression(_ expression: AnyTransition<S>) -> [AnyTransition<S>] {
        [expression]
    }
    
    public static func buildExpression<T: Transition>(_ expression: T) -> [AnyTransition<S>] where T.S == S {
        [expression.toAny()]
    }
    
    public static func buildExpression(_ expression: ()) -> [AnyTransition<S>] {
        []
    }
    
    public static func buildBlock(_ components: [AnyTransition<S>]...) -> [AnyTransition<S>] {
        components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [[AnyTransition<S>]]) -> [AnyTransition<S>] {
        components.flatMap { $0 }
    }
    
    public static func buildLimitedAvailability(_ component: [AnyTransition<S>]) -> [AnyTransition<S>] {
        component
    }
}
