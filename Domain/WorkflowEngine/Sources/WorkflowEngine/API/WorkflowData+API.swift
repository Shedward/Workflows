//
//  WorkflowData+API.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import API
import Foundation

extension API.WorkflowData {
    public init(model: WorkflowData) {
        self.init(data: model.data)
    }
}

extension WorkflowData {
    public init(api: API.WorkflowData) {
        self.init(data: api.data)
    }
}
