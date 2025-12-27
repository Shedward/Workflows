//
//  ArrayBuilder.swift
//  Core
//
//  Created by Vlad Maltsev on 27.12.2025.
//

@resultBuilder
public enum ArrayBuilder<Element> {
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.flatMap { $0 }
    }
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }

    public static func buildExpression(_ expression: [Element]) -> [Element] {
        expression
    }

    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }

    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }

    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }

    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }

    public static func buildFinalResult(_ component: [Element]) -> [Element] {
        component
    }
}

