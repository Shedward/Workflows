//
//  SetDependencies.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 22.02.2026.
//

struct SetDependencies: DataBinding {
    let container: DependenciesContainer

    func dependency<Value>(for key: String, at dependency: inout Dependency<Value>) throws where Value : Sendable {
        guard let dependencyValue = container.dependency(forKey: key) else {
            throw Failure("No dependency \(String(describing: Value.self)) for key \(key)")
        }

        guard let typedDependency = dependencyValue as? Value else {
            throw Failure("Dependency \(dependencyValue) can not be casted to \(Value.self)")
        }

        dependency.storage = ValueStorage(typedDependency)
    }
}
