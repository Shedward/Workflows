//
//  DependenciesContainer.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 22.02.2026.
//

public final class DependenciesContainer: Sendable {
    private let dependencies: [String: any Sendable]

    public var keys: Set<String> {
        Set(dependencies.keys)
    }

    public init(_ dependencies: [String: any Sendable] = [:]) {
        self.dependencies = dependencies
    }

    public func dependency(forKey key: String) -> (any Sendable)? {
        dependencies[key]
    }
}
