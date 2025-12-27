//
//  Actions.swift
//  Workflow
//
//  Created by Vlad Maltsev on 28.12.2025.
//

import Core

public protocol Actions: Action {

    @ArrayBuilder<Action>
    var actions: [Action] { get }
}

extension Actions {
    public func run() async throws {
        for action in actions {
            try await action.run()
        }
    }
}
