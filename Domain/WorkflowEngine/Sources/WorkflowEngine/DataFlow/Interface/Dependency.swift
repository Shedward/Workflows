//
//  Dependency.swift
//  Workflow
//
//  Created by Vlad Maltsev on 03.01.2026.
//

@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    var storage: ValueStorage?

    public var wrappedValue: Value {
        storage.boundValue(of: "Dependency", boundBy: "SetDependencies")
    }

    public init(key: StaticString? = nil) {
    }
}
