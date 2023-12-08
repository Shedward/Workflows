//
//  NewWorkflowProvider.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

public protocol NewWorkflowProvider {
    var id: String { get }
    var name: String { get }
    func workflows() async throws -> [AnyNewWorkflow]
}
