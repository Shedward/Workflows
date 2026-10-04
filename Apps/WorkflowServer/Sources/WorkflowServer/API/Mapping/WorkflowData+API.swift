//
//  WorkflowData+API.swift
//  WorkflowEngine
//
//  Created by Vlad Maltsev on 09.01.2026.
//

import API
import Foundation
import WorkflowEngine

extension API.WorkflowData {
    init(model: WorkflowEngine.WorkflowData) {
        self.init(data: model.data)
    }
}

extension WorkflowEngine.WorkflowData {
    init(api: API.WorkflowData) {
        self.init(data: api.data)
    }
}
