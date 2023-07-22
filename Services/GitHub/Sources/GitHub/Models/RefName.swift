//
//  RefName.swift
//  Created by Vladislav Maltsev on 22.07.2023.
//

public struct RefName: RawRepresentable {
    public var rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
