//
//  WorkflowAction.swift
//
//
//  Created by v.maltsev on 29.08.2023.
//

public protocol WorkflowAction {
    associatedtype Input
    associatedtype Output

    var id: String { get }
    var title: String { get }

    func perform(_ input: Input) async throws -> Output
}

public extension WorkflowAction {
    var id: String {
        String(describing: type(of: self))
    }
}
