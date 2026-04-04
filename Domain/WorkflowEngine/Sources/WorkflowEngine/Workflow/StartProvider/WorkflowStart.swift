//
//  WorkflowStart.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

import Core

public struct WorkflowStart: Sendable {
    public var title: String?
    public var data: WorkflowData

    public init(title: String? = nil, data: WorkflowData = .init()) {
        self.title = title
        self.data = data
    }

    public static let manual = WorkflowStart()
}

extension WorkflowStart: Modifiers {
    public func input<V: WorkflowValue>(_ key: String, to value: V) throws -> Self {
        var copy = self
        try copy.data.set(key, value)
        return copy
    }
}
