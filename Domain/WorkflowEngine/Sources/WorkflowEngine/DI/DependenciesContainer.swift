//
//  DependenciesContainer.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 22.02.2026.
//

import Dispatch

public final class DependenciesContainer: @unchecked Sendable {
    private var dependencies: [String: Sendable] = [:]
    private let queue = DispatchQueue(label: "DependenciesContainer")

    public init() {
    }

    public func set(_ dependency: Sendable, forKey key: String) {
        queue.sync {
            dependencies[key] = dependency
        }
    }
    
    public func dependency(forKey key: String) -> Sendable? {
        queue.sync {
            dependencies[key]
        }
    }
}
