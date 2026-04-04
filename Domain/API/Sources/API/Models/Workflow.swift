//
//  Workflow.swift
//  API
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Rest

public struct Workflow: JSONBody, Identifiable {
    public let id: String
    public let stateId: [String]
    public let transitions: [Transition]

    public init(id: String, stateId: [String], transitions: [Transition]) {
        self.id = id
        self.stateId = stateId
        self.transitions = transitions
    }
}
