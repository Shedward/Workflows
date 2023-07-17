//
//  PlainTextBody.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation

struct PlainTextBody: RestBodyCodable {
    let body: String

    init(_ body: String) {
        self.body = body
    }

    static func fromData(_ data: Data) throws -> PlainTextBody {
        guard let body = String(data: data, encoding: .utf8) else {
            throw EError("Failed to encode \(data) to String with UTF8")
        }
        return PlainTextBody(body)
    }

    func data() throws -> Data? {
        body.data(using: .utf8)
    }
}
