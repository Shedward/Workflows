//
//  MockFailure.swift
//
//
//  Created by v.maltsev on 25.09.2023.
//

public struct MockFailure: Error, Equatable {
    public let description: String

    public init(_ description: String) {
        self.description = description
    }
}
