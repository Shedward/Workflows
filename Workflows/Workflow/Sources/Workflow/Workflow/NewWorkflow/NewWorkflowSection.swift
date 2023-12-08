//
//  NewWorkflowSection.swift
//
//
//  Created by Vlad Maltsev on 07.12.2023.
//

public struct NewWorkflowSection {
    public let id: String
    public let title: String
    public let workflows: Result<[AnyNewWorkflow], Error>
    
    public init(id: String, title: String, workflows: Result<[AnyNewWorkflow], Error>) {
        self.id = id
        self.title = title
        self.workflows = workflows
    }
}
