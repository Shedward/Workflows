//
//  TransitionProcess.swift
//  Workflow
//
//  Created by Vlad Maltsev on 24.12.2025.
//

public protocol TransitionProcess {
    var id: TransitionProcessID { get }

    func start() async throws -> TransitionResult
}

public extension TransitionProcess {
    var id: TransitionProcessID {
        String(describing: type(of: self))
    }
}

public typealias TransitionProcessID = String
