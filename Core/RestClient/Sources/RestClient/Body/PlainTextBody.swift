//
//  PlainTextBody.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation
import Prelude

public struct PlainTextBody: RestBodyCodable {
    public let body: String

    public init(_ body: String) {
        self.body = body
    }

    public static func fromData(_ data: Data) throws -> PlainTextBody {
        guard let body = String(data: data, encoding: .utf8) else {
            throw Failure("Failed to encode \(data) to String with UTF8")
        }
        return PlainTextBody(body)
    }

    public func data() throws -> Data? {
        body.data(using: .utf8)
    }
}
