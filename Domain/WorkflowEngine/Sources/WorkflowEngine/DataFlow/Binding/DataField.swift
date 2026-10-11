//
//  DataField.swift
//  WorkflowEngine
//
//  Created by Мальцев Владислав on 03.04.2026.
//

public struct DataField: Sendable, Hashable {
    public let key: String
    public let valueType: String
}

extension Collection where Element == DataField {
    /// A stable order for sets of fields that leave the engine as arrays.
    public func sortedByKey() -> [DataField] {
        sorted { $0.key < $1.key }
    }
}
