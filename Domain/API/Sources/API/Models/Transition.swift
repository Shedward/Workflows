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
    public let toState: String

    public init(processId: String, fromState: String, toState: String) {
        self.processId = processId
        self.fromState = fromState
        self.toState = toState
    }
}
