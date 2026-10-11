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
    public mutating func bind<Binding: DataBinding>(_ binding: Binding) throws {
        var binding = binding
        try bind(&binding)
    }
}
