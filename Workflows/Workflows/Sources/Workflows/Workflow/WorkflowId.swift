//
//  WorkflowId.swift
//
//
//  Created by Vlad Maltsev on 07.10.2023.
//

public struct WorkflowIdPrefix {
    let rawValue: String
}

public struct WorkflowId {
    let rawValue: String
}

extension WorkflowId: Hashable { }
