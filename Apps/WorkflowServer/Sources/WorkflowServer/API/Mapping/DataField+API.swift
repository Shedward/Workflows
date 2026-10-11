//
//  DataField+API.swift
//  WorkflowServer
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import API
import WorkflowEngine

extension API.DataField {
    init(model: WorkflowEngine.DataField) {
        self.init(key: model.key, valueType: model.valueType)
    }
}
