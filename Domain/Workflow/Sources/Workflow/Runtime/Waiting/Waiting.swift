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
}

extension Waiting {
    public struct Time: Codable, Sendable {
        public let date: Date

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
    }

    public struct WorkflowFinished: Codable, Sendable {
        public let instanceId: WorkflowInstanceID

        public init(id: WorkflowInstanceID) {
            self.instanceId = id
        }
    }
}


