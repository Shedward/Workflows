//
//  Workflow.swift
//  API
//
//  Created by Vlad Maltsev on 20.02.2026.
//

import Rest

public struct Workflow: JSONBody, Identifiable {
    public let id: String
    public let states: [String]
    public let transitions: [Transition]

    public init(id: String, states: [String], transitions: [Transition]) {
        self.id = id
        self.states = states
        self.transitions = transitions
    }
}
