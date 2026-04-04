//
//  Waiting.swift
//  Workflow
//
//  Created by Vlad Maltsev on 30.12.2025.
//

import Foundation

public enum Waiting: Codable, Sendable {
    case time(Time)
    case workflowFinished(WorkflowFinished)
    case asking(Asking)
}

extension Waiting {
    public struct Time: Codable, Sendable {
        public static func until(_ date: Date) -> Self {
            Time(date: date)
        }

        public static func after(seconds: Double) -> Self {
            Time(date: Date().addingTimeInterval(seconds))
        }

        public static func after(minutes: Double) -> Self {
            .after(seconds: minutes * 60)
        }

        public static func after(hours: Double) -> Self {
            .after(seconds: hours * 3600)
        }

        public static func after(days: Int) -> Self {
            .after(seconds: TimeInterval(days) * 86_400)
        }

        public let date: Date

        public init(date: Date) {
            self.date = date
        }
    }

    public struct WorkflowFinished: Codable, Sendable {
        public let instanceId: WorkflowInstanceID

        public init(id: WorkflowInstanceID) {
            self.instanceId = id
        }
    }

    public struct Asking: Codable, Sendable {
        public let prompt: Prompt?
        public let expectedFields: [AskField]

        public init(prompt: Prompt?, expectedFields: [AskField]) {
            self.prompt = prompt
            self.expectedFields = expectedFields
        }
    }

    public struct AskField: Codable, Sendable {
        public let key: String
        public let valueType: String

        public init(key: String, valueType: String) {
            self.key = key
            self.valueType = valueType
        }
    }
}
