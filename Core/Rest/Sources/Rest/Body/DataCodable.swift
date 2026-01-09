//
//  RestBodyCodable.swift
//  Rest
//
//  Created by Vlad Maltsev on 21.12.2025.
//

import Foundation

public protocol DataEncodable: Sendable {
    func data() throws -> Data?
}

public protocol DataDecodable: Sendable {
    init(data: Data) throws
}

public typealias DataCodable = DataEncodable & DataDecodable
