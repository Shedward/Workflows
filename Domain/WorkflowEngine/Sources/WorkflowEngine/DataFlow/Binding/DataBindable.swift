//
//  Activity.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

public protocol DataBindable: Sendable {
    mutating func bind<Binding: DataBinding>(_ binding: inout Binding) throws
}

extension DataBindable {
    mutating public func bind<Binding: DataBinding>(_ binding: Binding) throws {
        var binding = binding
        try bind(&binding)
    }

    public func binded<Binding: DataBinding>(_ binding: inout Binding) throws -> Self {
        var copy = self
        try copy.bind(&binding)
        return copy
    }

    public func binded<Binding: DataBinding>(_ binding: Binding) throws -> Self {
        var binding = binding
        return try binded(&binding)
    }
}
