//
//  TransitionID.swift
//  API
//
//  Created by Vlad Maltsev on 23.02.2026.
//

import Rest

public struct TransitionID: JSONBody {
    public let workflow: String
    public let processId: String
    public let from: String

    public init(workflow: String, processId: String, from: String) {
        self.workflow = workflow
        self.processId = processId
        self.from = from
    }
}
