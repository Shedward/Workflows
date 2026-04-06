//
//  WorkflowStart.swift
//  WorkflowEngine
//
//  Created by Claude on 03.04.2026.
//

import Core
import os

public struct WorkflowStart: Sendable {
    public static let manual = WorkflowStart()

    public var title: String?
    public var data: WorkflowData

    public init(title: String? = nil, data: WorkflowData = .init()) {
        self.title = title
        self.data = data
    }
}

extension WorkflowStart: Modifiers {
    public func input<V: WorkflowValue>(_ key: String, to value: V) -> Self {
        var copy = self
        do {
            try copy.data.set(key, value)
        } catch {
            Logger(scope: .workflow)?
                .error("Failed to convert input\(key, privacy: .public): \(V.self, privacy: .public)")
        }
        return copy
    }
}
