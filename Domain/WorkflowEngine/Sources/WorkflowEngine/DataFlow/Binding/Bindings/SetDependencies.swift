//
//  SetDependencies.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 22.02.2026.
//

struct SetDependencies: DataBinding {
    let container: DependenciesContainer

    func dependency<Value>(for key: String, at dependency: inout Dependency<Value>) throws where Value: Sendable {
        guard let dependencyValue = container.dependency(forKey: key) else {
            throw WorkflowsError.DependencyBindingFailed(key: key, reason: .missing)
        }

        guard let typedDependency = dependencyValue as? Value else {
            throw WorkflowsError.DependencyBindingFailed(
                key: key,
                reason: .typeMismatch(
                    expected: String(describing: Value.self),
                    actual: String(describing: type(of: dependencyValue))
                )
            )
        }

        dependency.storage = ValueStorage(typedDependency)
    }
}
