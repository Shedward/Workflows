//
//  AnyTransition.swift
//  Workflow
//
//  Created by Vlad Maltsev on 26.12.2025.
//

public protocol AnyTransition: Sendable {
    var id: TransitionID { get }
    var process: TransitionProcess { get }

    var fromStateId: StateID { get }
    var toStateId: StateID { get }
}
