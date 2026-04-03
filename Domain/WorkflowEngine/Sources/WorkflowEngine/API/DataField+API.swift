//
//  DataField+API.swift
//  WorkflowEngine
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import API

extension API.DataField {
    public init(model: WorkflowEngine.DataField) {
        self.init(key: model.key, valueType: model.valueType)
    }
}

extension WorkflowEngine.DataField {
    public init(api: API.DataField) {
        self.init(key: api.key, valueType: api.valueType)
    }
}
