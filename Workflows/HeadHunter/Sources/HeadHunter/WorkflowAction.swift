//
//  WorkflowAction.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public protocol WorkflowAction {

    var id: String { get }
    var title: String { get }

    func perform() async throws
}

public extension WorkflowAction {
    var id: String {
        String(describing: type(of: self))
    }
}
