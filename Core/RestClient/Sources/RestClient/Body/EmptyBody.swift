//
//  EmptyBody.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation

public struct EmptyBody: DataCodable {
    public init() {
    }

    public init(data: Data) throws {
    }

    public func data() throws -> Data? {
        nil
    }
}

extension EmptyBody: Defaultable {}
