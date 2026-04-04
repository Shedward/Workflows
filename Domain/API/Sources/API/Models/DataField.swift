//
//  DataField.swift
//  API
//
//  Created by Мальцев Владислав on 03.04.2026.
//

import Rest

public struct DataField: JSONBody, Hashable {
    public let key: String
    public let valueType: String

    public init(key: String, valueType: String) {
        self.key = key
        self.valueType = valueType
    }
}
