//
//  ArrayBuilder.swift
//  
//
//  Created by Vlad Maltsev on 06.11.2023.
//

@resultBuilder
public struct ArrayBuilder<Element> {
    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }
    
    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }
    
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }
    
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }
    
    public static func buildExpression(_ expression: ()) -> [Element] {
        []
    }
    
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }
    
    public static func buildLimitedAvailability(_ component: [Element]) -> [Element] {
        component
    }
}

extension Array {
    public init(@ArrayBuilder<Element> builder: () -> [Element]) {
        self.init(builder())
    }
    
    public static func build(@ArrayBuilder<Element> builder: () -> [Element]) -> Self {
        self.init(builder: builder)
    }
}
