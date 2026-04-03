//
//  DataField.swift
//  WorkflowEngine
//
//  Created by Мальцев Владислав on 03.04.2026.
//

public struct DataField: Sendable, Codable, Hashable {
    public let key: String
    public let valueType: String
}
