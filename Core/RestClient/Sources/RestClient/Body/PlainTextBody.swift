//
//  PlainTextBody.swift
//  RestClient
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Core
import Foundation

public struct PlainTextBody: DataCodable {
    public let body: String

    public init(_ body: String) {
        self.body = body
    }

    public init(data: Data) throws {
        guard let body = String(data: data, encoding: .utf8) else {
            throw Failure("Failed to encode \(data) to String with UTF8")
        }
        self.init(body)
    }

    public func data() throws -> Data? {
        body.data(using: .utf8)
    }
}
