//
//  TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol TransitionProcess {
    var id: TransitionProcessID { get }

    func start(context: inout WorkflowContext) async throws -> TransitionResult
}

public extension TransitionProcess {
    var id: TransitionProcessID {
        String(describing: self)
    }
}

public typealias TransitionProcessID = String
