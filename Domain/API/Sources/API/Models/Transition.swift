//
//  Transition.swift
//  API
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Rest

public struct Transition: JSONBody {
    public let processId: String
    public let fromState: String
    public let targets: [String]
    public let trigger: String

    public init(processId: String, fromState: String, targets: [String], trigger: String) {
        self.processId = processId
        self.fromState = fromState
        self.targets = targets
        self.trigger = trigger
    }
}
