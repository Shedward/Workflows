//
//  Action.swift
//  Workflow
//
//  Created by Vlad Maltsev on 27.12.2025.
//

public protocol Action: TransitionProcess {
    func run() async throws
}
