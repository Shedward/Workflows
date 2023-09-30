//
//  ExecutableTermination.swift
//  Workflows
//
//  Created by Vladislav Maltsev on 28.07.2023.
//

import Foundation

public struct ExecutableTermination {
    public enum Reason {
        case exit
        case uncaughtSignal
        case unknown

        init(processTerminationReason: Process.TerminationReason) {
            switch processTerminationReason {
            case .exit:
                self = .exit
            case .uncaughtSignal:
                self = .uncaughtSignal
            @unknown default:
                self = .unknown
            }
        }
    }

    public let reason: Reason
    public let status: Int32

    public var isSuccessful: Bool {
        reason == .exit && status == 0
    }
    
    public static var successful: ExecutableTermination {
        .init(reason: .exit, status: 0)
    }

    public init(reason: Reason = .exit, status: Int32) {
        self.reason = reason
        self.status = status
    }
}
