//
//  RestBodyCodable.swift
//  Created by Vladislav Maltsev on 18.07.2023.
//

import Foundation

public protocol RestBodyEncodable {
    func data() throws -> Data?
}

public protocol RestBodyDecodable {
    static func fromData(_ data: Data) throws -> Self
}

public typealias RestBodyCodable = RestBodyEncodable & RestBodyDecodable
