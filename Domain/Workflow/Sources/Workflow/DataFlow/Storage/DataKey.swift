//
//  InputOutputData.swift
//  Workflow
//
//  Created by Vlad Maltsev on 02.01.2026.
//

public struct AnyDataKey: Hashable, Sendable {
    var name: String
    var type: ObjectIdentifier
}

public struct DataKey<Value>: Hashable, Sendable {
    public let name: String

    public func eraseToAny() -> AnyDataKey {
        .init(name: name, type: ObjectIdentifier(Value.self))
    }
}
